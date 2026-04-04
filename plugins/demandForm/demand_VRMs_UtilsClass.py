#-----------------------------------------------------------
# Licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#---------------------------------------------------------------------
# Tim Hancock 2017

"""
Series of functions to deal with restrictionsInProposals. Defined as static functions to allow them to be used in forms ... (not sure if this is the best way ...)

"""
from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel,
    QDockWidget,
    QDialog,
    QLabel,
    QPushButton,
    QApplication,
    QComboBox, QSizePolicy, QGridLayout,
    QWidget, QVBoxLayout, QHBoxLayout, QFormLayout, QTableView, QTableWidgetItem, QListView, QGroupBox,
    QRadioButton, QButtonGroup, QDataWidgetMapper, QSpacerItem, QLineEdit, QSpacerItem,
    QProgressDialog, QProgressBar, QTextEdit, QTabWidget
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap,
    QImage, QPainter, QStandardItem, QIntValidator
)

from qgis.PyQt.QtCore import (
    QObject,
    QTimer,
    QThread,
    pyqtSignal,
    pyqtSlot, Qt,QModelIndex, QDateTime
)

from qgis.PyQt.QtSql import (
    QSqlDatabase, QSqlQuery, QSqlQueryModel, QSqlRelation, QSqlRelationalTableModel, QSqlRelationalDelegate,QSqlTableModel
)

from qgis.core import (
    Qgis,
    QgsExpressionContextScope,
    QgsExpressionContextUtils,
    QgsExpression,
    QgsFeatureRequest,
    QgsMessageLog,
    QgsFeature,
    QgsGeometry,
    QgsTransaction,
    QgsTransactionGroup,
    QgsProject,
    QgsSettings,
    QgsDataSourceUri
)

from qgis.gui import *
import functools
import time, datetime
import os, uuid
#import cv2
import math

from abc import ABCMeta
from TOMs.generateGeometryUtils import generateGeometryUtils
from TOMs.restrictionTypeUtilsClass import (TOMsParams, TOMsLayers, originalFeature, RestrictionTypeUtilsMixin, TOMsConfigFile)
from restrictionsWithGNSS.fieldRestrictionTypeUtilsClass import (FieldRestrictionTypeUtilsMixin)

from TOMs.ui.TOMsCamera import (formCamera)
from restrictionsWithGNSS.ui.imageLabel import (imageLabel)
from .vrmWidget import vrmWidget
from .countWidget import countWidget

from .RBKC2022countWidget import RBKCcountWidget

cv2_available = True
try:
    import cv2
except ImportError:
    QgsMessageLog.logMessage("Not able to import cv2 ...", tag="TOMs panel")
    cv2_available = False

import uuid
from TOMs.core.TOMsMessageLog import TOMsMessageLog
from .demand_form import VRM_DemandForm

ZOOM_LIMIT = 5

class vrmParams(TOMsParams):
    def __init__(self):
        TOMsParams.__init__(self)
        #self.iface = iface

        #TOMsMessageLog.logMessage("In gpsParams.init ...", level=Qgis.Info)

        self.TOMsParamsList.extend([
                          "CameraNr",
                          "Enumerator",
                          "CurrentSurvey",
                          "rotateCamera"
                               ])

class DemandUtilsMixin(FieldRestrictionTypeUtilsMixin):
    def __init__(self, iface):
        #RestrictionTypeUtilsMixin.__init__(self, iface)
        self.iface = iface
        self.settings = QgsSettings()

        self.params = vrmParams()

        #self.TOMsUtils = RestrictionTypeUtilsMixin(self.iface)

    def getDemandSurveyType(self):

        self.TOMsConfigFileObject = TOMsConfigFile()
        self.TOMsConfigFileObject.initialiseTOMsConfigFile() # assume OK to read

        surveyType = None

        surveyType = self.TOMsConfigFileObject.getTOMsConfigElement('Demand', 'DemandSurveyType')
        TOMsMessageLog.logMessage("In DemandUtils:getDemandSurveyType: {}".format(surveyType),
                                  level=Qgis.Info)

        return surveyType

    def getMainTabName(self):

        self.TOMsConfigFileObject = TOMsConfigFile()
        self.TOMsConfigFileObject.initialiseTOMsConfigFile() # assume OK to read

        mainTabName = None
        self.TOMsConfigFileObject = TOMsConfigFile()
        self.TOMsConfigFileObject.initialiseTOMsConfigFile() # assume OK to read

        mainTabName = self.TOMsConfigFileObject.getTOMsConfigElement('Demand', 'MainTabName')
        TOMsMessageLog.logMessage("In DemandUtils:getMainTabName: {}".format(mainTabName),
                                  level=Qgis.Info)

        return mainTabName

    def getExtraTabName(self):

        self.TOMsConfigFileObject = TOMsConfigFile()
        self.TOMsConfigFileObject.initialiseTOMsConfigFile() # assume OK to read

        extraTabName = None

        extraTabName = self.TOMsConfigFileObject.getTOMsConfigElement('Demand', 'ExtraTabName')
        TOMsMessageLog.logMessage("In DemandUtils:getExtraTabName: {}".format(extraTabName),
                                  level=Qgis.Info)

        return extraTabName

    def allowCopyFromPreviousDay(self):

        self.TOMsConfigFileObject = TOMsConfigFile()
        self.TOMsConfigFileObject.initialiseTOMsConfigFile() # assume OK to read

        allowedToCopyFromPreviousDay = False

        option = self.TOMsConfigFileObject.getTOMsConfigElement('Demand', 'AllowCopyFromPreviousDay')
        TOMsMessageLog.logMessage("In DemandUtils:allowCopyFromPreviousDay: {}".format(option),
                                  level=Qgis.Info)

        if option == 'Yes':
            allowedToCopyFromPreviousDay = True

        return allowedToCopyFromPreviousDay

    def getDemandFieldsListFromConfigFile(self):

        self.TOMsConfigFileObject = TOMsConfigFile()
        self.TOMsConfigFileObject.initialiseTOMsConfigFile() # assume OK to read

        fields = self.TOMsConfigFileObject.getTOMsConfigElement('Demand', 'DemandFields')
        #demandFieldsList = []
        if fields:
            demandFieldsList = fields.split('\n')
            return demandFieldsList

        return None

    def setDefaultFieldRestrictionDetails(self, currRestriction, currRestrictionLayer, currDate):
        TOMsMessageLog.logMessage("In DemandUtils:setDefaultFieldRestrictionDetails: {}".format(currRestrictionLayer.name()), level=Qgis.Info)

        # TODO: Need to check whether or not these fields exist. Also need to retain the last values and reuse
        # gis.stackexchange.com/questions/138563/replacing-action-triggered-script-by-one-supplied-through-qgis-plugin

        try:
            currRestriction.setAttribute("LastUpdateDateTime", currDate)
        except Exception as e:
            TOMsMessageLog.logMessage("In setDefaultFieldRestrictionDetails. Problem with setting LastUpdateDateTime: {}".format(e),
                                      level=Qgis.Info)

    def setupFieldRestrictionDialog(self, restrictionDialog, currRestrictionLayer, currRestriction):

        TOMsMessageLog.logMessage("In DemandUtilsMixin:setupFieldRestrictionDialog: {}: {}".format(currRestrictionLayer.name(), currRestriction.attribute("GeometryID")),
                                  level=Qgis.Info)

        self.params.getParams()

        status = self.mapOtherFields(restrictionDialog, currRestrictionLayer, currRestriction)

        # Create a copy of the feature
        self.origFeature = originalFeature()
        self.origFeature.setFeature(currRestriction)

        if restrictionDialog is None:
            reply = QMessageBox.information(None, "Error",
                                            "setupFieldRestrictionDialog. Correct form not found",
                                            QMessageBox.Ok)
            TOMsMessageLog.logMessage(
                "In setupRestrictionDialog. dialog not found",
                level=Qgis.Info)
            return

        restrictionDialog.attributeForm().disconnectButtonBox()
        button_box = restrictionDialog.findChild(QDialogButtonBox, "button_box")

        if button_box is None:
            TOMsMessageLog.logMessage(
                "In setupRestrictionDialog. button box not found",
                level=Qgis.Warning)
            return

        button_box.accepted.connect(functools.partial(self.onSaveFieldRestrictionDetails, currRestriction,
                                      currRestrictionLayer, restrictionDialog))

        button_box.rejected.connect(functools.partial(self.onRejectFieldRestrictionDetailsFromForm, restrictionDialog, currRestrictionLayer))

        restrictionDialog.attributeForm().attributeChanged.connect(functools.partial(self.onAttributeChangedClass2_local, currRestriction, currRestrictionLayer))

        # setup widget mapping
        #currRestrictionModel = self.setupRestrictionInSurveyModel(self.surveyID, currRestriction)
        #self.setupRestrictionMapping(currRestrictionModel)

        """
        Check survey type ... If not vrm, then create widgets and populate fields
        """
        surveyType = self.getDemandSurveyType()
        TOMsMessageLog.logMessage("In setupFieldRestrictionDialog. surveyType: {}".format(surveyType), level=Qgis.Info)

        self.setMainTabName(restrictionDialog)

        if surveyType == 'Count':
            TOMsMessageLog.logMessage("In setupFieldRestrictionDialog. Calling addCountWidget ...", level=Qgis.Info)
            self.addCountWidget(restrictionDialog, currRestrictionLayer, currRestriction)
        else:
            TOMsMessageLog.logMessage("In setupFieldRestrictionDialog. Calling addVRMWidget ...", level=Qgis.Info)
            self.addVRMWidget(restrictionDialog, currRestrictionLayer, currRestriction)

        self.photoDetails_field(restrictionDialog, currRestrictionLayer, currRestriction)
        
        #self.addScrollBars(restrictionDialog)

        """
            set form location (based on last position)
        """

        TOMsMessageLog.logMessage("In setupFieldRestrictionDialog. set form location ...", level=Qgis.Info)

        dw = restrictionDialog.width()
        dh = restrictionDialog.height()
        restrictionDialog.setGeometry(int(self.readLastUsedDetails(currRestrictionLayer.name(), 'geometry_x', 200)),
                                      int(self.readLastUsedDetails(currRestrictionLayer.name(), 'geometry_y', 200)),
                                      int(self.readLastUsedDetails(currRestrictionLayer.name(), 'geometry_w', dw)),
                                      int(self.readLastUsedDetails(currRestrictionLayer.name(), 'geometry_h', dh))
                                      )

    def mapOtherFields(self, restrictionDialog, currRestrictionLayer, currRestriction):

        TOMsMessageLog.logMessage("In mapOtherFields. SurveyID: {}".format(self.surveyID), level=Qgis.Info)
        # is there a better way ???
        currSurveyName = self.getCurrSurveyName(self.surveyID)
        TOMsMessageLog.logMessage("In mapOtherFields. currSurveyName: {}".format(currSurveyName), level=Qgis.Info)

        SurveyBeatTitleWidget = restrictionDialog.findChild(QWidget, "SurveyBeatTitle")

        try:
            SurveyBeatTitleWidget.setText(currSurveyName)
        except Exception as e:
            reply = QMessageBox.information(None, "Error",
                                                "mapOtherFields. Problem setting SurveyName: {} for SurveyID: {}. Issue is {}".format(currSurveyName, self.surveyID, e),
                                                QMessageBox.Ok)
            return False

        if self.dbConn.driverName() == 'QPSQL':
            queryString = 'SELECT COALESCE(\"RoadName\",\'No Road Name\'), COALESCE(\"RestrictionLength\", 0), COALESCE(\"Capacity\", 0), \"RestrictionTypeID\", \"Notes\" FROM mhtc_operations.\"Supply\" WHERE \"GeometryID\" = \'{}\''.format(currRestriction.attribute("GeometryID"))
        else:
            queryString = "SELECT COALESCE(\"RoadName\", '[No Road Name]'), COALESCE(\"RestrictionLength\", '[Not known]'), COALESCE(\"Capacity\", '[Not known]'), \"RestrictionTypeID\", \"Notes\" FROM \"Supply\" WHERE \"GeometryID\" = '{}'".format(currRestriction.attribute("GeometryID"))

        TOMsMessageLog.logMessage("In mapOtherFields: queryString: {}".format(queryString), level=Qgis.Info)
        query = QSqlQuery(queryString)

        RoadName, RestrictionLength, Capacity, RestrictionTypeID, SupplyChangesNotes = range(5)  # ?? see https://realpython.com/python-pyqt-database/#executing-dynamic-queries-string-formatting

        if not query.next():
            TOMsMessageLog.logMessage(
                "In mapOtherFields: error with query ... {} ".format(query.lastError().text()),
                level=Qgis.Warning)

        TOMsMessageLog.logMessage(
                "In mapOtherFields: RoadName: {}, RestrictionLength: {}".format(query.value(RoadName), query.value(RestrictionLength)),
                level=Qgis.Info)

        try:

            RoadNameWidget = restrictionDialog.findChild(QWidget, "RoadName")
            RoadNameWidget.setText(query.value(RoadName))

            RestrictionLengthWidget = restrictionDialog.findChild(QWidget, "RestrictionLength")
            RestrictionLengthWidget.setText(str(query.value(RestrictionLength)))

            CapacityWidget = restrictionDialog.findChild(QWidget, "Capacity")
            CapacityWidget.setText(str(query.value(Capacity)))
            self.Capacity = Capacity

            SupplyNotesWidget = restrictionDialog.findChild(QWidget, "SupplyChangesNotes")
            SupplyNotesWidget.setText(str(query.value(SupplyChangesNotes)))

        except Exception as e:
            reply = QMessageBox.information(None, "Error",
                                                "mapOtherFields. Problem setting attributes: {} for SurveyID: {}. Issue is {}".format(currSurveyName, self.surveyID, e),
                                                QMessageBox.Ok)
            #return False

        # get restriction details

        GeometryID = currRestriction.attribute('GeometryID')

        RestrictionDescription = generateGeometryUtils.getLookupDescription(self.RESTRICTION_TYPES, query.value(RestrictionTypeID))

        title = "{RestrictionDescription} [{GeometryID}]".format(RestrictionDescription=RestrictionDescription,
                                                             GeometryID=GeometryID)

        RestrictionDetailsWidget = restrictionDialog.findChild(QWidget, "RestrictionDetails")
        RestrictionDetailsWidget.setText(title)


    def onAttributeChangedClass2_local(self, currFeature, layer, fieldName, value):

        TOMsMessageLog.logMessage(
            "In field:FormOpen:onAttributeChangedClass 2 - layer: " + str(layer.name()) + " (" + fieldName + "): " + str(value), level=Qgis.Info)
        try:
            currFeature[layer.fields().indexFromName(fieldName)] = value
        except Exception as e:
            reply = QMessageBox.information(None, "Error",
                                                "onAttributeChangedClass2. Update failed for: " + str(layer.name()) + " (" + fieldName + "): " + str(value),
                                                QMessageBox.Ok)  # rollback all changes

        return

    def onSaveFieldRestrictionDetails(self, currFeature, currFeatureLayer, dialog):
        TOMsMessageLog.logMessage("In onSaveFieldRestrictionDetails:  currFeatureID: {}; {}".format(currFeature.id(), currFeature.attribute('GeometryID')), level=Qgis.Info)

        # set update time on tablet (or when not set) !!!

        if self.dbConn.driverName() != 'QPSQL' or currFeature.attribute("DemandSurveyDateTime") is None:

            try:
                currFeature.setAttribute("DemandSurveyDateTime", QDateTime.currentDateTime())
                currFeature.setAttribute("Enumerator", self.enumerator)
            except Exception as e:
                reply = QMessageBox.information(None, "Information", "Problem setting date/time: {}".format(e), QMessageBox.Ok)

        currFeatureLayer.updateFeature(currFeature)

        try:

            if self.getDemandSurveyType() == 'Count':

                # Check that the demand value it not too much more than the capacity
                demandTotal = self.checkDemand()
                if demandTotal > self.Capacity:
                    reply = QMessageBox.question(None, "Question", "There is a difference between Capacity ({}) and Demand: ({}). Is this correct?".format(self.Capacity, demandTotal),
                                                 QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
                    if reply == QMessageBox.StandardButton.No:
                        QMessageBox.information(None, "Action Required",
                                                "Please reopen the restriction and amend the demand values",
                                                QMessageBox.Ok)

                self.countModel.submitAll()

            currFeatureLayer.commitChanges()

        except Exception as e:
            reply = QMessageBox.information(None, "Information", "Problem committing changes: {}".format(e), QMessageBox.Ok)

        TOMsMessageLog.logMessage("In onSaveDemandDetails: changes committed", level=Qgis.Info)

        """
            save form location for reuse
        """
        self.storeLastUsedDetails(currFeatureLayer.name(), 'geometry_x', dialog.geometry().x())
        self.storeLastUsedDetails(currFeatureLayer.name(), 'geometry_y', dialog.geometry().y())
        self.storeLastUsedDetails(currFeatureLayer.name(), 'geometry_h', dialog.geometry().height())
        self.storeLastUsedDetails(currFeatureLayer.name(), 'geometry_w', dialog.geometry().width())

        status = dialog.close()

    def onRejectFieldRestrictionDetailsFromForm(self, restrictionDialog, currFeatureLayer):
        TOMsMessageLog.logMessage("In onRejectFieldRestrictionDetailsFromForm", level=Qgis.Info)

        '''
        try:
            self.camera1.endCamera()
            #self.camera2.endCamera()
            #self.camera3.endCamera()
        except:
            None
        '''
        
        currFeatureLayer.rollBack()
        if self.getDemandSurveyType() == 'Count':
            self.countModel.revertAll()

        """
            save form location for reuse
        """
        self.storeLastUsedDetails(currFeatureLayer.name(), 'geometry_x', restrictionDialog.geometry().x())
        self.storeLastUsedDetails(currFeatureLayer.name(), 'geometry_y', restrictionDialog.geometry().y())

        restrictionDialog.reject()

        #del self.mapTool

    def getDbConn(self, testLayerName):

        # new get the connection details for testLayer
        try:
            testLayer = QgsProject.instance().mapLayersByName(testLayerName)[0]
            provider = testLayer.dataProvider()
            TOMsMessageLog.logMessage("In getDbConn: db type is {}".format(provider.name()), level=Qgis.Warning)
        except Exception as e:
            #QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Error opening test layer {}".format(e)))
            TOMsMessageLog.logMessage("In getDbConn: error opening test layer {}".format(e), level=Qgis.Warning)
            return None

        testUriName = testLayer.dataProvider().dataSourceUri()  # this returns a string with the db name and layer, eg. 'Z:/Tim//SYS2012_Demand_VRMs.gpkg|layername=VRMs'
        demand_schema = None
            
        if provider.name() == 'postgres':
            # get the URI containing the connection parameters
            # create a PostgreSQL connection using QSqlDatabase
            dbConn = QSqlDatabase.addDatabase('QPSQL')
            TOMsMessageLog.logMessage("In getDbConn. uri: {}".format(testUriName), level=Qgis.Warning)
            # check to see if it is valid
            if dbConn.isValid():
                # set the parameters needed for the connection
                if len(provider.uri().service()) > 0:
                    dbConn.setConnectOptions("service={}".format(provider.uri().service()))
                else:
                    # need to get the details of the connection ...
                    dbConn.setHostName(provider.uri().host())
                    dbConn.setDatabaseName(provider.uri().database())
                    dbConn.setPort(int(provider.uri().port()))
                    dbConn.setUserName(provider.uri().username)
                    dbConn.setPassword(provider.uri().password)

            demand_schema = QgsDataSourceUri(testUriName).schema()
            TOMsMessageLog.logMessage("In dbConn. demand_schema: {}".format(demand_schema), level=Qgis.Warning)

        else:
            dbName = testUriName[:testUriName.find('|')]
            TOMsMessageLog.logMessage("In getDbConn. dbName: {}".format(dbName), level=Qgis.Warning)

            dbConn = QSqlDatabase.addDatabase("QSQLITE")
            dbConn.setDatabaseName(dbName)


        return dbConn, demand_schema

    def addVRMWidget(self, restrictionDialog, currRestrictionLayer, currRestriction):

        TOMsMessageLog.logMessage("In addVRMWidget ... ", level=Qgis.Info)
        demandTab = restrictionDialog.findChild(QWidget, "Demand")
        demandLayout = demandTab.layout()
        demandForm = vrmWidget(self.dbConn, self.demand_schema)
        demandForm.startOperation.connect(self.startProgressDialog)
        demandForm.progressUpdated.connect(self.showProgress)
        demandForm.endOperation.connect(self.endProgressDialog)

        currGeometryID = currRestriction.attribute("GeometryID")

        # get fields to display

        demandFields = self.getDemandFieldsListFromConfigFile()

        demandForm.populateDemandWidget(self.surveyID, currGeometryID, demandFields)

        demandLayout.addWidget(demandForm, 0, 0)

        buttonLayout = QVBoxLayout()
        buttonLayout.setSpacing(50)
        addButton = QPushButton("+")
        removeButton = QPushButton("-")
        buttonLayout.addWidget(addButton)
        buttonLayout.addWidget(removeButton)

        demandLayout.addLayout(buttonLayout, 0, 1, alignment=QtCore.Qt.AlignRight | QtCore.Qt.AlignTop)

        addButton.clicked.connect(functools.partial(demandForm.insertVrm, self.surveyID, currGeometryID))
        removeButton.clicked.connect(demandForm.deleteVrm)

    def addCountWidget(self, restrictionDialog, currRestrictionLayer, currRestriction):

        TOMsMessageLog.logMessage("In addCountWidget ... ", level=Qgis.Info)

        demandTab = restrictionDialog.findChild(QWidget, "Demand")
        demandLayout = demandTab.layout()
        thisCountWidget = countWidget(self.dbConn, self.demand_schema, self.surveyID, currRestriction)
        thisCountWidget.setupUi()
        self.countModel = thisCountWidget.getCountModel()

        #currGeometryID = currRestriction.attribute("GeometryID")

        demandLayout.addWidget(thisCountWidget)

        extraTabLabel = self.getExtraTabName()

        thisCountWidget.populateDemandWidget(extraTabLabel)

        self.countWidget = thisCountWidget

    @pyqtSlot()
    def startProgressDialog(self):
        TOMsMessageLog.logMessage("In utils::startProgressDialog ... ", level=Qgis.Info)
        self.progressDialog = QProgressDialog("Operation in progress.", "", 0, 100)
        self.progressDialog.setWindowModality(Qt.WindowModal)
        self.progressDialog.setWindowTitle("Resetting position ...")
        self.progressDialog.show()

    @pyqtSlot(int)
    def showProgress(self, percentComplete):
        TOMsMessageLog.logMessage("In utils::showProgress ... {}".format(percentComplete), level=Qgis.Info)
        self.progressDialog.setValue(percentComplete)

    @pyqtSlot()
    def endProgressDialog(self):
        TOMsMessageLog.logMessage("In utils::endProgressDialog ... ", level=Qgis.Info)
        self.progressDialog.close()

    def getCurrSurveyName(self, currSurveyID):
        # display list
        TOMsMessageLog.logMessage(
            "In getCurrSurveyName: currSurveyID: {}".format(currSurveyID), level=Qgis.Info)
        currSurveyName = ''

        surveyList = list()

        query = QSqlQuery()
        if self.dbConn.driverName() == 'QPSQL':
            queryStr = 'SELECT \"SurveyID\", \"BeatTitle\" FROM "{}".\"Surveys\" ORDER BY \"SurveyID\" ASC;'.format(self.demand_schema)
        else:
            queryStr = 'SELECT \"SurveyID\", \"BeatTitle\" FROM \"Surveys\" ORDER BY \"SurveyID\" ASC;'

        if not query.exec(queryStr):
            reply = QMessageBox.information(None, "Error",
                                            "Problem getting current survey name - {} {} {}\n".format(query.lastQuery(),
                                                                                       query.lastError().type(),
                                                                                       query.lastError().databaseText()
                                                                                       ), QMessageBox.Ok)
            return None

        SurveyID, BeatTitle = range(2)  # ?? see https://realpython.com/python-pyqt-database/#executing-dynamic-queries-string-formatting

        while query.next():
            TOMsMessageLog.logMessage("In getCurrSurveyName: surveyID: {}, BeatTitle: {}".format(query.value(SurveyID), query.value(BeatTitle)), level=Qgis.Info)
            surveyList.append(query.value(BeatTitle))
            if int(currSurveyID) == int(query.value(SurveyID)):
                currSurveyName = query.value(BeatTitle)
                break

        return currSurveyName

    def setupRestrictionInSurveyModel(self, surveyID, currRestriction):
        pass

    def setMainTabName(self, restrictionDialog):

        TOMsMessageLog.logMessage("In setMainTabName ... ", level=Qgis.Info)
        demandTab = restrictionDialog.findChild(QTabWidget, "Details")
        idx_main = demandTab.indexOf(restrictionDialog.findChild(QWidget, "Demand"))

        mainTabText = self.getMainTabName()

        TOMsMessageLog.logMessage("In setMainTabName ... newText: {}; idx: {}".format(mainTabText, idx_main), level=Qgis.Info)

        if mainTabText:
            demandTab.setTabText (idx_main, mainTabText)

    def checkDemand(self):

        demandTotal = 0
        for widget in self.countWidget.findChildren(QLineEdit):
            TOMsMessageLog.logMessage("In checkDemand ... considering: {} {}".format(widget.objectName(), widget.text()), level=Qgis.Info)

            if widget.objectName()[:2] == "Nr":
                try:
                    ival = int(widget.text())
                except ValueError:
                    ival = 0
                demandTotal = demandTotal + ival

        return demandTotal