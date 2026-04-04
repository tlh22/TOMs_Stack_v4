# -*- coding: utf-8 -*-
"""
/***************************************************************************
 loadOcc
                                 A QGIS plugin
 Loads data from occupancy survey
                              -------------------
        begin                : 2018-09-14
        git sha              : $Format:%H$
        copyright            : (C) 2018 by MHTC
        email                : th@mhtc.co.uk
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""
#from PyQt4.QtCore import QSettings, QTranslator, qVersion, QCoreApplication
#from PyQt4.QtGui import QAction, QIcon

from qgis.PyQt.QtCore import (
    QObject,
    QTimer,
    pyqtSignal,
    QSettings, QTranslator, qVersion, QCoreApplication, Qt, QModelIndex,
)

from qgis.PyQt.QtGui import (
    QIcon, QStandardItemModel, QStandardItem,
    QPixmap
                             )
from qgis.PyQt.QtWidgets import (
    QAction,
    QWidget,
    QMessageBox,
    QDialog,
    QVBoxLayout, QCheckBox, QListView, QAbstractItemView, QFormLayout, QDialogButtonBox, QLabel, QGroupBox,
    QDockWidget, QFileDialog
)

from qgis.PyQt.QtSql import (
    QSqlDatabase, QSqlQuery, QSqlQueryModel, QSqlRelation, QSqlRelationalTableModel, QSqlRelationalDelegate
)

from TOMs.core.TOMsMessageLog import TOMsMessageLog

from qgis.core import (
    Qgis,
    QgsMessageLog,
    QgsProject,
    QgsApplication, QgsExpression, QgsFeatureRequest, QgsMapLayer,
    QgsExpressionContextUtils, QgsFeature, QgsTransaction
)

from qgis.gui import (QgsMapCanvas)

# Initialize Qt resources from file resources.py
from .resources import *
# Import the code for the dialog
from loadDemand.load_Occ_dialog import loadOccDialog
from TOMsExport.checkableMapLayerList import checkableMapLayerListCtrl, checkableMapLayerList
from TOMs.core.TOMsTransaction import TOMsTransaction
from TOMs.restrictionTypeUtilsClass import (TOMsConfigFile)

import os
import os.path
from pydoc import locate
#from qgis.gui import *
#from qgis.core import *
from html.parser import HTMLParser


# See following for using QgsMapLayerComboBox - https://stackoverflow.com/questions/44079328/python-load-module-in-parent-to-prevent-overwrite-problems

class loadDemand:
    """QGIS Plugin Implementation."""

    def __init__(self, iface):
        """Constructor.

        :param iface: An interface instance that will be passed to this class
            which provides the hook by which you can manipulate the QGIS
            application at run time.
        :type iface: QgsInterface
        """
        # Save reference to the QGIS interface
        self.iface = iface
        # initialize plugin directory
        self.plugin_dir = os.path.dirname(__file__)
        # initialize locale
        locale = QSettings().value('locale/userLocale')[0:2]
        locale_path = os.path.join(
            self.plugin_dir,
            'i18n',
            'loadOcc_{}.qm'.format(locale))

        if os.path.exists(locale_path):
            self.translator = QTranslator()
            self.translator.load(locale_path)

            if qVersion() > '4.3.3':
                QCoreApplication.installTranslator(self.translator)


        # Declare instance attributes
        self.actions = []
        self.menu = self.tr(u'&loadDemand')
        # TODO: We are going to let the user set this up in a future iteration
        self.toolbar = self.iface.addToolBar(u'loadDemand')
        self.toolbar.setObjectName(u'loadDemand')

        #self.canvas = QgsMapCanvas()
        #self.root = QgsProject.instance().layerTreeRoot()
        self.myHTMLParser = HTMLParser()

    # noinspection PyMethodMayBeStatic
    def tr(self, message):
        """Get the translation for a string using Qt translation API.

        We implement this ourselves since we do not inherit QObject.

        :param message: String for translation.
        :type message: str, QString

        :returns: Translated version of message.
        :rtype: QString
        """
        # noinspection PyTypeChecker,PyArgumentList,PyCallByClass
        return QCoreApplication.translate('loadDemand', message)


    def add_action(
        self,
        icon_path,
        text,
        callback,
        enabled_flag=True,
        add_to_menu=True,
        add_to_toolbar=True,
        status_tip=None,
        whats_this=None,
        parent=None):

        # Create the dialog (after translation) and keep reference
        self.dlg = loadOccDialog()

        icon = QIcon(icon_path)
        action = QAction(icon, text, parent)
        action.triggered.connect(callback)
        action.setEnabled(enabled_flag)

        if status_tip is not None:
            action.setStatusTip(status_tip)

        if whats_this is not None:
            action.setWhatsThis(whats_this)

        if add_to_toolbar:
            self.toolbar.addAction(action)

        if add_to_menu:
            self.iface.addPluginToMenu(
                self.menu,
                action)

        self.actions.append(action)

        return action

    def initGui(self):
        """Create the menu entries and toolbar icons inside the QGIS GUI."""

        icon_path = ':/plugins/loadOcc/icon.png'
        self.add_action(
            icon_path,
            text=self.tr(u'Load Demand'),
            callback=self.run,
            parent=self.iface.mainWindow())

        # Need to set up signals for layerChanged

    def unload(self):
        """Removes the plugin menu item and icon from QGIS GUI."""
        for action in self.actions:
            self.iface.removePluginMenu(
                self.tr(u'&loadDemand'),
                action)
            self.iface.removeToolBarIcon(action)
        # remove the toolbar
        del self.toolbar


    def run(self):
        """Run method that performs all the real work"""
        # show the dialog

        self.setupUi()
        self.dlg.show()
        # Run the dialog event loop
        result = self.dlg.exec_()

        # See if OK was pressed
        if result:

            self.surveyType = self.getDemandSurveyType()
            TOMsMessageLog.logMessage("In loadDemand. surveyType: {}".format(self.surveyType),
                                      level=Qgis.Warning)

            surveysToProcess = self.itemList.getSelectedItems()

            # get folder for processing
            searchFolder = str(QFileDialog.getExistingDirectory(self.iface.mainWindow(), "Select Directory", QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('project_path')))

            TOMsMessageLog.logMessage("search folder is {} ...".format(searchFolder),
                                      level=Qgis.Warning)

            # https://stackoverflow.com/questions/3964681/find-all-files-in-a-directory-with-extension-txt-in-python
            for root, dirs, files in os.walk(searchFolder):
                for file in files:
                    if file.endswith(".gpkg"):
                        self.currGpkg = os.path.abspath(os.path.join(root, file))
                        TOMsMessageLog.logMessage("Processing {} ...".format(self.currGpkg), level=Qgis.Warning)

                        dbConn = QSqlDatabase.addDatabase("QSQLITE")
                        dbConn.setDatabaseName(self.currGpkg)

                        if not dbConn.open():
                            QMessageBox.critical(None, "Cannot open database",
                                                 "Unable to establish a database connection.\n\n"
                                                 "Click Cancel to exit.", QMessageBox.Cancel)
                        else:
                            self.processGpkg(dbConn, surveysToProcess)

                        dbConn.close()


    def processGpkg(self, dbConn, surveysToProcess):

        TOMsMessageLog.logMessage("In processGpkg ...", level=Qgis.Warning)

        # see if the table "RestrictionsInSurveys" exists
        tablesInCurrGpkg = dbConn.tables()

        if 'RestrictionsInSurveys' in tablesInCurrGpkg:
            TOMsMessageLog.logMessage("In processGpkg. RestrictionsInSurveys found ...", level=Qgis.Warning)

            for currSurveyItem in surveysToProcess:
                TOMsMessageLog.logMessage("Processing {} ...".format(currSurveyItem.text()), level=Qgis.Warning)
                currSurveyID = self.surveyDictionary[currSurveyItem.text()]
                TOMsMessageLog.logMessage("currSurveyID is {} ...".format(currSurveyID),
                                          level=Qgis.Warning)

                self.processRestrictionsForSurvey(dbConn, currSurveyID)


    def processRestrictionsForSurvey(self, dbConn, currSurveyID):
        TOMsMessageLog.logMessage("In processRestrictionsForSurvey ...", level=Qgis.Warning)

        # get any details that have been "Done"

        try:
            restrictionsInSurveysLayer = QgsProject.instance().mapLayersByName('RestrictionsInSurveys')[0]
        except Exception as e:
            TOMsMessageLog.logMessage(
                "In processRestrictionsForSurvey. Could not find restrictionsInSurveys layer", level=Qgis.Warning)
            QMessageBox.critical(None, "processRestrictionsForSurvey",
                                 "Could not find restrictionsInSurveys layer {}".format(e),
                                 "Click Cancel to exit.", QMessageBox.Cancel)
            return False

        if self.surveyType == 'Count':
            demandLayer = QgsProject.instance().mapLayersByName('Counts')[0]
            TOMsMessageLog.logMessage("In processRestrictionsForSurvey. Processing Counts ...", level=Qgis.Warning)
        else:
            demandLayer = QgsProject.instance().mapLayersByName('VRMs')[0]
            TOMsMessageLog.logMessage("In processRestrictionsForSurvey. Processing VRMs ...", level=Qgis.Warning)

        for l in [restrictionsInSurveysLayer, demandLayer]:
            l.startEditing()

        # TODO: set up transaction

        query = QSqlQuery(
        "SELECT SurveyID, GeometryID, DemandSurveyDateTime, Enumerator, Done, SuspensionReference, SuspensionReason, SuspensionLength, NrBaysSuspended, SuspensionNotes, Photos_01, Photos_02, Photos_03, \'{}\' AS CaptureSource FROM RestrictionsInSurveys WHERE SurveyID = {} AND Done IS TRUE".format(self.currGpkg, currSurveyID)
        , dbConn)
        query.exec()

        SurveyID, GeometryID, DemandSurveyDateTime, Enumerator, Done, \
        SuspensionReference, SuspensionReason, SuspensionLength, NrBaysSuspended, SuspensionNotes, \
        Photos_01, Photos_02, Photos_03, CaptureSource = range(14)

        #SurveyID, BeatTitle = range(2)  # ?? see https://realpython.com/python-pyqt-database/#executing-dynamic-queries-string-formatting

        demandCopyStatus = True

        while query.next():
            TOMsMessageLog.logMessage("Considering: currSurveyID: {}; GeometryID: {}".format(query.value(SurveyID), query.value(GeometryID)), level=Qgis.Info)

            thisRecord = query.record()
            status = self.copyAttributesToMasterLayer(thisRecord, restrictionsInSurveysLayer, query.value(SurveyID), query.value(GeometryID))

            # status is false when error or no rows found
            if status:
                if self.surveyType == 'Count':
                    demandCopyStatus = self.processCounts(dbConn, demandLayer, query.value(SurveyID),
                                                      query.value(GeometryID))
                else:
                    demandCopyStatus = self.processVRMs(dbConn, demandLayer, query.value(SurveyID), query.value(GeometryID))

                if not demandCopyStatus:
                    TOMsMessageLog.logMessage(
                        "Error occurred in processDemands", level=Qgis.Warning)
                    break

        if demandCopyStatus:
            TOMsMessageLog.logMessage("**** Committing: currSurveyID: {}; GeometryID: {}".format(query.value(SurveyID), query.value(GeometryID)),
                level=Qgis.Info)
            #commitStatus = localTransactionGroup.commit()
            for l in [restrictionsInSurveysLayer, demandLayer]:
                try:
                    l.commitChanges()
                    #dbConn.commit()
                except Exception as e:
                    TOMsMessageLog.logMessage(
                        "In processRestrictionsForSurvey. Error occurred committing details for surveyID {}".format(query.value(SurveyID)), level=Qgis.Warning)
                    QMessageBox.critical(None, "processRestrictionsForSurvey",
                                         "Unexcepted error occurred during commit {}".format(e),
                                         "Click Cancel to exit.", QMessageBox.Cancel)
                    return False

        else:
            TOMsMessageLog.logMessage("**** ROLLING BACK: currSurveyID: {}; GeometryID: {}".format(query.value(SurveyID), query.value(GeometryID)),
                level=Qgis.Warning)
            for l in [restrictionsInSurveysLayer, demandLayer]:
                try:
                    l.rollBack()
                    #dbConn.rollback()
                except Exception as e:
                    TOMsMessageLog.logMessage(
                        "In processRestrictionsForSurvey. Error occurred rolling back details for surveyID {}".format(query.value(SurveyID)), level=Qgis.Warning)
                    QMessageBox.critical(None, "processRestrictionsForSurvey",
                                         "Unexcepted error occurred during commit {}".format(e),
                                         "Click Cancel to exit.", QMessageBox.Cancel)
                    return False

            #localTransactionGroup.rollback()

    def processVRMs(self, dbConn, vrmsLayer, currSurveyID, currGeometryID):
        TOMsMessageLog.logMessage("In processVRMs for {}, {} ...".format(currSurveyID, currGeometryID), level=Qgis.Warning)

        # select all VRMs for this survey/GeometryID and add to layer

        query = QSqlQuery(
        "SELECT SurveyID, GeometryID, PositionID, VRM, InternationalCodeID, VehicleTypeID, PermitTypeID, ParkingActivityTypeID, ParkingMannerTypeID, Notes FROM VRMs WHERE SurveyID = {} AND GeometryID = \'{}\'".format(currSurveyID, currGeometryID)
        , dbConn)
        query.exec()

        SurveyID, GeometryID, PositionID, VRM, InternationalCodeID, VehicleTypeID, PermitTypeID, ParkingActivityTypeID, ParkingMannerTypeID, Notes = range(10)

        #SurveyID, BeatTitle = range(2)  # ?? see https://realpython.com/python-pyqt-database/#executing-dynamic-queries-string-formatting

        while query.next():
            TOMsMessageLog.logMessage("Considering VRMs: currSurveyID: {}; GeometryID: {}".format(query.value(SurveyID), query.value(GeometryID)), level=Qgis.Warning)

            thisRecord = query.record()
            fields = vrmsLayer.dataProvider().fields()
            newRow = QgsFeature()
            newRow.setFields(fields)

            for fieldIdx in range(SurveyID, Notes+1):

                fieldValue = thisRecord.field(fieldIdx).value()
                if fieldValue is not None:
                    try:

                        idxVRMsField = vrmsLayer.fields().indexFromName(thisRecord.fieldName(fieldIdx))
                        vrmsFieldType = vrmsLayer.fields().at(idxVRMsField).typeName()
                        TOMsMessageLog.logMessage("In processVRMs: Adding field {} of type {}: {}".format(
                            thisRecord.fieldName(fieldIdx), vrmsFieldType, fieldValue), level=Qgis.Warning)
                        newRow[idxVRMsField] = self.convertType(vrmsFieldType, fieldValue)

                    except IndexError:
                        TOMsMessageLog.logMessage("In processVRMs: Index error occurred updating field {} in survey {} to {}".format(
                            thisRecord.fieldName(fieldIdx), query.value(SurveyID), query.value(GeometryID)), level=Qgis.Warning)
                        return False
                    except KeyError:
                        TOMsMessageLog.logMessage("In processVRMs. Key error occurred updating field {} in survey {} to {}".format(
                            thisRecord.fieldName(fieldIdx), query.value(SurveyID), query.value(GeometryID)), level=Qgis.Warning)
                        return False
                    except Exception as e:
                        TOMsMessageLog.logMessage("In processVRMs. Error occurred updating field {} in {}".format(thisRecord.fieldName(fieldIdx), str(currGeometryID)), level=Qgis.Warning)
                        QMessageBox.critical(None, "processVRMs",
                                                       "Unexcepted error occurred {}".format(e),
                                                       "Click Cancel to exit.", QMessageBox.Cancel)
                        return False

            try:
                vrmsLayer.addFeature(newRow)
            except Exception as e:
                TOMsMessageLog.logMessage("In processVRMs. Error occurred updating field {} in {}".format(thisRecord.fieldName(fieldIdx), str(currGeometryID)), level=Qgis.Warning)
                QMessageBox.critical(None, "processVRMs", "Unexcepted error occurred {}".format(e), "Click Cancel to exit.", QMessageBox.Cancel)
                return False
                
        return True

    def processCounts(self, dbConn, countsLayer, currSurveyID, currGeometryID):
        TOMsMessageLog.logMessage("In processCounts for {}, {} ...".format(currSurveyID, currGeometryID), level=Qgis.Info)

        query = QSqlQuery(
        # (for RBKC 2022) "SELECT SurveyID, GeometryID, NrCars, NrLGVs, NrMCLs, NrTaxis, NrPCLs, NrEScooters, NrDocklessPCLs, NrOGVs, NrMiniBuses, NrBuses, NrSpaces, Notes, DoubleParkingDetails, NrCars_Suspended, NrLGVs_Suspended, NrMCLs_Suspended, NrTaxis_Suspended, NrPCLs_Suspended, NrEScooters_Suspended, NrDocklessPCLs_Suspended, NrOGVs_Suspended, NrMiniBuses_Suspended, NrBuses_Suspended, NrCarsIdling, NrCarsParkedIncorrectly, NrLGVsIdling, NrLGVsParkedIncorrectly, NrMCLsIdling, NrMCLsParkedIncorrectly, NrTaxisIdling, NrTaxisParkedIncorrectly, NrOGVsIdling, NrOGVsParkedIncorrectly, NrMiniBusesIdling, NrMiniBusesParkedIncorrectly, NrBusesIdling, NrBusesParkedIncorrectly, NrCarsWithDisabledBadgeParkedInPandD FROM Counts WHERE SurveyID = {} AND GeometryID = \'{}\'".format(currSurveyID, currGeometryID)
        "SELECT SurveyID, GeometryID, NrCars, NrLGVs, NrMCLs, NrTaxis, NrPCLs, NrEScooters, NrDocklessPCLs, NrOGVs, NrMiniBuses, NrBuses, NrSpaces, Notes, DoubleParkingDetails, NrCars_Suspended, NrLGVs_Suspended, NrMCLs_Suspended, NrTaxis_Suspended, NrPCLs_Suspended, NrEScooters_Suspended, NrDocklessPCLs_Suspended, NrOGVs_Suspended, NrMiniBuses_Suspended, NrBuses_Suspended, NrCarsWaiting, NrLGVsWaiting, NrMCLsWaiting, NrTaxisWaiting, NrOGVsWaiting, NrMiniBusesWaiting, NrBusesWaiting, NrCarsIdling, NrLGVsIdling, NrMCLsIdling, NrTaxisIdling, NrOGVsIdling, NrMiniBusesIdling, NrBusesIdling FROM Counts WHERE SurveyID = {} AND GeometryID = \'{}\'".format(currSurveyID, currGeometryID)
        , dbConn)
        TOMsMessageLog.logMessage("In processCounts {} ...".format(query.lastQuery()),
                                  level=Qgis.Info)
        try:
            query.exec()
        except Exception as e:
            TOMsMessageLog.logMessage(
                "In processCounts. Error finding record {}, {}".format(currSurveyID, currGeometryID),
                level=Qgis.Warning)
            QMessageBox.critical(None, "processCounts",
                                 "Unexcepted error occurred {}".format(e),
                                 "Click Cancel to exit.", QMessageBox.Cancel)

        """  For RBKC 2022
        SurveyID, GeometryID, NrCars, NrLGVs, NrMCLs, NrTaxis, NrPCLs, NrEScooters, NrDocklessPCLs, NrOGVs, NrMiniBuses, NrBuses, NrSpaces, Notes, \
        DoubleParkingDetails, \
        NrCars_Suspended, NrLGVs_Suspended, NrMCLs_Suspended, NrTaxis_Suspended, NrPCLs_Suspended, NrEScooters_Suspended, \
        NrDocklessPCLs_Suspended, NrOGVs_Suspended, NrMiniBuses_Suspended, NrBuses_Suspended, \
        NrCarsIdling, NrCarsParkedIncorrectly, NrLGVsIdling, NrLGVsParkedIncorrectly, NrMCLsIdling, NrMCLsParkedIncorrectly, NrTaxisIdling, NrTaxisParkedIncorrectly, NrOGVsIdling, NrOGVsParkedIncorrectly, NrMiniBusesIdling, NrMiniBusesParkedIncorrectly, NrBusesIdling, NrBusesParkedIncorrectly, \
        NrCarsWithDisabledBadgeParkedInPandD = range(40)
        """

        SurveyID, GeometryID, NrCars, NrLGVs, NrMCLs, NrTaxis, NrPCLs, NrEScooters, NrDocklessPCLs, NrOGVs, NrMiniBuses, NrBuses, NrSpaces, Notes, \
        DoubleParkingDetails, \
        NrCars_Suspended, NrLGVs_Suspended, NrMCLs_Suspended, NrTaxis_Suspended, NrPCLs_Suspended, NrEScooters_Suspended, \
        NrDocklessPCLs_Suspended, NrOGVs_Suspended, NrMiniBuses_Suspended, NrBuses_Suspended, \
        NrCarsWaiting, NrLGVsWaiting, NrMCLsWaiting, NrTaxisWaiting, NrOGVsWaiting, NrMiniBusesWaiting, NrBusesWaiting, \
        NrCarsIdling, NrLGVsIdling, NrMCLsIdling, NrTaxisIdling, NrOGVsIdling, NrMiniBusesIdling, NrBusesIdling = range(39)

        #SurveyID, BeatTitle = range(2)  # ?? see https://realpython.com/python-pyqt-database/#executing-dynamic-queries-string-formatting

        demandCopyStatus = True

        while query.next():

            TOMsMessageLog.logMessage("Updating count details: currSurveyID: {}; GeometryID: {}".format(query.value(SurveyID), query.value(GeometryID)), level=Qgis.Info)

            thisRecord = query.record()
            demandCopyStatus = self.copyAttributesToMasterLayer(thisRecord, countsLayer, query.value(SurveyID), query.value(GeometryID))

            if demandCopyStatus == False:
                QMessageBox.information(self.iface.mainWindow(), "In processCounts",  "Error occurred updating record surveyID {}, GeometryID {}:".format(currSurveyID, currGeometryID))
                break

        TOMsMessageLog.logMessage("Finished processCounts for {}, {} ...".format(currSurveyID, currGeometryID),
                                  level=Qgis.Info)
        return demandCopyStatus

    # as per recommendation from @freylis, compile once only
    #CLEANR = re.compile('<.*?>')

    def cleanhtml(self, raw_html):
        #self.myHTMLParser.feed(raw_html)
        #self.myHTMLParser.close()
        cleantext = self.myHTMLParser.handle_data(raw_html)
        return cleantext

    def convertType(self, type, value):

        if type == 'bool':
            value = bool(value)

        if type == 'int4':
            try:
                value = int(value)
            except ValueError:
                value = 0
            except TypeError:
                TOMsMessageLog.logMessage("In convertType. error with value: " + str(value),
                                          level=Qgis.Warning)
                value = 0

        """if type == 'varchar':
            value = self.cleanhtml(value)"""

        """for type in (int, float):
            try:
                return type(value)
            except ValueError:
                return 0"""

        return value

    def copyAttributesToMasterLayer(self, featureDetails, masterLayer, currSurveyID, currGeometryID):

        # copies relevant details into the master Layer

        status = True

        TOMsMessageLog.logMessage("In copyAttributesToMasterLayer. GeometryID: " + str(currGeometryID),
                                 level=Qgis.Info)
        # Now find the row for this GeometryID in masterLayer
        query = ('"SurveyID" = {} AND "GeometryID" = \'{}\' AND ("Done" = \'false\' OR "Done" IS NULL)').format(currSurveyID, currGeometryID)
        expr = QgsExpression(query)
        selection = masterLayer.getFeatures(QgsFeatureRequest(expr))

        try:
            masterRow = next(row for row in selection)
            rowFound = True
        except StopIteration:
            rowFound = False
            status = False

        if rowFound == True:

            nrFields = masterRow.attributeCount()
            idx_SurveyID = masterRow.fieldNameIndex("SurveyID")
            idx_GeometryID = masterRow.fieldNameIndex("GeometryID")

            TOMsMessageLog.logMessage("In copyAttributesToMasterLayer. idx_SurveyID: {}; idx_GeometryID: {}".format(idx_SurveyID, idx_GeometryID),
                                                 level=Qgis.Info)

            TOMsMessageLog.logMessage("In copyAttributesToMasterLayer. Copying details for: {}".format(currGeometryID),
                                                 level=Qgis.Info)
            for fieldIdx in range(1, nrFields):

                if fieldIdx in [idx_SurveyID, idx_GeometryID]:
                    continue

                # find out what the field is in the master layer
                masterFieldName = masterRow.fields().at(fieldIdx).name()
                masterFieldType = masterRow.fields().at(fieldIdx).typeName()
                TOMsMessageLog.logMessage("In copyAttributesToMasterLayer: field {} {} is type {}".format(
                    masterFieldName, fieldIdx, masterFieldType), level=Qgis.Info)

                # get the same named field in the gkpg
                idxFeatureField = featureDetails.indexOf(masterFieldName)
                currfieldValue = featureDetails.field(idxFeatureField).value()

                if currfieldValue is not None and str(currfieldValue) != 'NULL':

                    fieldValue = self.convertType(masterFieldType, currfieldValue)

                    try:
                        TOMsMessageLog.logMessage("In copyAttributesToMasterLayer: Updating field {} in {} with {}".format(
                            featureDetails.fieldName(idxFeatureField), currGeometryID, fieldValue), level=Qgis.Info)
                        masterRow.setAttribute(fieldIdx, fieldValue)
                    except IndexError:
                        TOMsMessageLog.logMessage("In copyAttributesToMasterLayer: Index error occurred updating field {} in {}".format(featureDetails.fieldName(fieldIdx), str(currGeometryID)), level=Qgis.Warning)
                        return False
                    except KeyError:
                        TOMsMessageLog.logMessage("In copyAttributesToMasterLayer. Key error occurred updating field {} in {}".format(featureDetails.fieldName(fieldIdx), str(currGeometryID)), level=Qgis.Warning)
                        return False
                    except Exception as e:
                        TOMsMessageLog.logMessage("In copyAttributesToMasterLayer. Error occurred updating field {} in {}".format(featureDetails.fieldName(fieldIdx), str(currGeometryID)), level=Qgis.Warning)
                        QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Unexcepted error occurred in copyAttributesToMasterLayer - {}".format(e)))
                        return False

            status = masterLayer.updateFeature(masterRow)

            if status == False:
                QMessageBox.information(self.iface.mainWindow(), "In copyAttributesToMasterLayer",  "Error occurred updating record surveyID {}, GeometryID {}:".format(currSurveyID, currGeometryID))

        else:
            return False

        return status

    def setupUi(self):

        self.dlg = QDialog()
        self.dlg.setWindowTitle("Import demand data")
        self.dlg.setWindowModality(Qt.ApplicationModal)

        self.generalLayout = QVBoxLayout()

        layerGroup = QGroupBox("Choose time periods to import")
        # test = QLabel()
        # test.setText("Choose layers to export and confirm location of output")
        # self.generalLayout.addWidget(test)

        surveyList = list()
        self.surveyDictionary = {}
        surveysLayer = QgsProject.instance().mapLayersByName('Surveys')[0]
        surveysIterator = surveysLayer.getFeatures()

        for currSurvey in surveysIterator:
            currSurvey.attribute("BeatTitle")
            surveyList.append(currSurvey.attribute("BeatTitle"))
            self.surveyDictionary[currSurvey.attribute("BeatTitle")] = currSurvey.attribute("SurveyID")

        # add map layer list
        self.itemList = checkableList(sorted(surveyList))
        vbox1 = QVBoxLayout()
        vbox1.addWidget(self.itemList)
        layerGroup.setLayout(vbox1)
        self.generalLayout.addWidget(layerGroup)

        # add file chooser
        #outputGroup = QGroupBox("Choose output file")
        #self.fileNameWidget = QgsFileWidget()
        #self.fileNameWidget.setStorageMode(QgsFileWidget.SaveFile)
        #self.fileNameWidget.setFilter("Geopackage (*.gpkg);;JPEG (*.jpg *.jpeg);;TIFF (*.tif)")
        #self.fileNameWidget.setSelectedFilter("Geopackage (*.gpkg)")
        #vbox2 = QVBoxLayout()
        #vbox2.addWidget(self.fileNameWidget)
        #outputGroup.setLayout(vbox2)
        #self.generalLayout.addWidget(outputGroup)

        # add buttons
        self.buttonBox = QDialogButtonBox(QDialogButtonBox.Ok
                                          | QDialogButtonBox.Cancel)
        self.buttonBox.accepted.connect(self.dlg.accept)
        self.buttonBox.rejected.connect(self.dlg.reject)
        self.generalLayout.addWidget(self.buttonBox)

        self.dlg.setLayout(self.generalLayout)
        checkableListCtrl(self.itemList)

    def getDemandSurveyType(self):

        surveyType = None
        self.TOMsConfigFileObject = TOMsConfigFile()
        self.TOMsConfigFileObject.initialiseTOMsConfigFile() # assume OK to read

        surveyType = self.TOMsConfigFileObject.getTOMsConfigElement('Demand', 'DemandSurveyType')
        TOMsMessageLog.logMessage("In DemandUtils:getDemandSurveyType: {}".format(surveyType),
                                  level=Qgis.Warning)

        return surveyType

class checkableListCtrl:
    """PyCalc Controller class."""
    def __init__(self, view):
        """Controller initializer."""
        self._view = view
        # Connect signals and slots
        self._connectSignals()

    def _connectSignals(self):
        """Connect signals and slots."""
        self._view.select_all_cb.clicked.connect(lambda: self._view.selectAllCheckChanged(self._view.select_all_cb, self._view.model))
        self._view.view.clicked.connect(lambda: self._view.listviewCheckChanged(self._view.model, self._view.select_all_cb))
        self._view.view.clicked[QModelIndex].connect(self._view.updateSelectedItems)

class checkableList(QWidget):

    # create a checkable list of the items

    def __init__(self, listToUse, parent=None):
        QWidget.__init__(self, parent)

        #itemList = listToUse
        #self.iface = iface

        """for layer in itemList:
            print(layer.name())"""

        self.selectedItems = []

        layout = QVBoxLayout()
        self.model = QStandardItemModel()

        self.select_all_cb = QCheckBox('Check All')
        self.select_all_cb.setChecked(True)
        self.select_all_cb.setStyleSheet('margin-left: 5px; font: bold')
        #self.select_all_cb.stateChanged.connect(lambda: selectAllCheckChanged(select_all_cb, model))
        layout.addWidget(self.select_all_cb)

        self.view = QListView()
        self.view.setEditTriggers(QAbstractItemView.NoEditTriggers)
        self.view.setSelectionMode(QAbstractItemView.NoSelection)
        self.view.setSelectionRectVisible(False)

        for itemFromList in listToUse:
            item = QStandardItem(itemFromList)
            # item.setFlags(Qt.ItemIsUserCheckable | Qt.ItemIsEnabled)
            # item.setData(QVariant(Qt.Checked), Qt.CheckStateRole)
            item.setCheckable(True)
            item.setSelectable(False)
            item.setCheckState(QtCore.Qt.Checked)
            self.model.appendRow(item)
            self.selectedItems.append(item)

        self.view.setModel(self.model)

        #view.clicked.connect(lambda: listviewCheckChanged(item, model, select_all_cb))

        layout.addWidget(self.view)

        self.setLayout(layout)
        """if parent:
            parent.setLayout(layout)
        else:
            window = QWidget()
            window.setLayout(layout)"""
        #window.show()

    def selectAllCheckChanged(self, select_all_cb, model):
        TOMsMessageLog.logMessage("IN selectAllCheckChanged",
                                 level=Qgis.Warning)
        for index in range(model.rowCount()):
            item = model.item(index)
            if item.isCheckable():
                if select_all_cb.isChecked():
                    item.setCheckState(QtCore.Qt.Checked)
                    self.selectedItems.append(item)
                else:
                    item.setCheckState(QtCore.Qt.Unchecked)
                    self.selectedItems.remove(item)

        TOMsMessageLog.logMessage("IN selectAllCheckChanged: len list {}".format(len(self.selectedItems)),
                                  level=Qgis.Warning)

    def listviewCheckChanged(self, model, select_all_cb):
        ''' updates the select all checkbox based on the listview '''
        # model = self.listview.model()
        TOMsMessageLog.logMessage("IN listviewCheckChanged",
                                 level=Qgis.Warning)
        items = [model.item(index) for index in range(model.rowCount())]
        if all(item.checkState() == QtCore.Qt.Checked for item in items):
            select_all_cb.setTristate(False)
            select_all_cb.setCheckState(QtCore.Qt.Checked)
        elif any(item.checkState() == QtCore.Qt.Checked for item in items):
            select_all_cb.setTristate(True)
            select_all_cb.setCheckState(QtCore.Qt.PartiallyChecked)
        else:
            select_all_cb.setTristate(False)
            select_all_cb.setCheckState(QtCore.Qt.Unchecked)

    def updateSelectedItems(self, index):
        #QMessageBox.information(self.iface.mainWindow(), "debug", "IN updateSelectedLayers: {}".format(self.model.itemFromIndex(index)))
        TOMsMessageLog.logMessage("IN updateSelectedItems: {}".format(index) ,
                                 level=Qgis.Warning)
        item = self.model.itemFromIndex(index)
        if item.checkState() == QtCore.Qt.Checked:
            self.selectedItems.append(item)
        else:
            self.selectedItems.remove(item)

    def getSelectedItems(self):
        return self.selectedItems

