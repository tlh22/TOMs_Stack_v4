""" ***


*** """
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
    QWidget, QVBoxLayout, QTableView, QTableWidgetItem, QLayout, QItemDelegate, QStyledItemDelegate, QLineEdit, QHeaderView
)

from qgis.PyQt.QtGui import (
    QIcon,
    QPixmap,
    QImage, QPainter
)

from qgis.PyQt.QtCore import (
    QObject,
    QTimer,
    QThread,
    pyqtSignal,
    pyqtSlot, Qt,QModelIndex
)

from qgis.PyQt.QtSql import (
    QSqlDatabase, QSqlQuery, QSqlQueryModel, QSqlRelation, QSqlRelationalTableModel, QSqlRelationalDelegate, QSqlTableModel
)

from qgis.core import (
    Qgis
)

from qgis.gui import *
import functools
import time, datetime
import os, uuid
import math

from abc import ABCMeta
from TOMs.generateGeometryUtils import generateGeometryUtils
from TOMs.restrictionTypeUtilsClass import (TOMsParams, TOMsLayers, originalFeature, RestrictionTypeUtilsMixin)
from restrictionsWithGNSS.fieldRestrictionTypeUtilsClass import (FieldRestrictionTypeUtilsMixin)

from TOMs.ui.TOMsCamera import (formCamera)
from restrictionsWithGNSS.ui.imageLabel import (imageLabel)

import uuid
from TOMs.core.TOMsMessageLog import TOMsMessageLog
from .demand_form import VRM_DemandForm

class vrmWidget(QTableView):

    progressUpdated = pyqtSignal(int)
    startOperation = pyqtSignal()
    endOperation = pyqtSignal()

    def __init__(self, dbConn, demand_schema):
        super(vrmWidget, self).__init__()
        TOMsMessageLog.logMessage("In vrmWidget:init ... ", level=Qgis.Info)
        self.dbConn = dbConn
        self.demand_schema = demand_schema

        self.vrmModel = QSqlRelationalTableModel(self, db=self.dbConn)
        #vrmsLayer = QgsProject.instance().mapLayersByName("VRMs")[0]
        #self.provider = vrmsLayer.dataProvider()

    def populateDemandWidget(self, surveyID, GeometryID, demandFields):

        TOMsMessageLog.logMessage("In vrmWidget:populateDemandWidget ... surveyID: {}; GeometryID: {}".format(surveyID, GeometryID), level=Qgis.Info)

        if self.dbConn.driverName() == 'QPSQL':
            table = '"{}"."VRMs"'.format(self.demand_schema)
            self.vrmModel.setTable(table)
            #self.vrmModel.setTable('demand' + '.\"VRMs\"')
        else:
            self.vrmModel.setTable('VRMs')

        self.vrmModel.setJoinMode(QSqlRelationalTableModel.LeftJoin)
        self.vrmModel.setEditStrategy(QSqlTableModel.OnFieldChange)

        filterString = "\"SurveyID\" = {} AND \"GeometryID\" = \'{}\'".format(surveyID, GeometryID)
        TOMsMessageLog.logMessage("In vrmWidget:populateDemandWidget ... filterString: {}".format(filterString), level=Qgis.Info)

        self.vrmModel.setFilter(filterString)
        #vrmModel.setFilter("SurveyID = 1 AND SectionID = 5")
        self.vrmModel.setSort(int(self.vrmModel.fieldIndex("PositionID")), Qt.AscendingOrder)
        #self.vrmModel.setHeaderData(self.vrmModel.fieldIndex("PositionID"), Qt.Horizontal, 'Pos')

        """
        It was a challenge to work out the required structure/format for accessing postgres records. The clue came from here - https://osgeo-fr.github.io/presentations_foss4gfr/2016/J2/SylvainPierre.pdf
        (slide 9) with the setTable instruction.
        """

        if self.dbConn.driverName() == 'QPSQL':
            self.vrmModel.setRelation(int(self.vrmModel.fieldIndex("VehicleTypeID")), QSqlRelation('demand_lookups'+'.\"VehicleTypes\"', '\"Code\"', '\"Description\"'))
            self.vrmModel.setRelation(int(self.vrmModel.fieldIndex('PermitTypeID')), QSqlRelation('demand_lookups'+'.\"PermitTypes\"', '\"Code\"', '\"Description\"'))
            self.vrmModel.setRelation(int(self.vrmModel.fieldIndex("InternationalCodeID")), QSqlRelation('demand_lookups'+'.\"InternationalCodes\"', '\"Code\"', '\"Description\"'))
            self.vrmModel.setRelation(int(self.vrmModel.fieldIndex("ParkingActivityTypeID")), QSqlRelation('demand_lookups'+'.\"ParkingActivityTypes\"', '\"Code\"', '\"Description\"'))
            self.vrmModel.setRelation(int(self.vrmModel.fieldIndex("ParkingMannerTypeID")), QSqlRelation('demand_lookups'+'.\"ParkingMannerTypes\"', '\"Code\"', '\"Description\"'))
        else:
            self.vrmModel.setRelation(int(self.vrmModel.fieldIndex("VehicleTypeID")),
                                      QSqlRelation('VehicleTypes', 'Code',
                                                   'Description'))
            self.vrmModel.setRelation(int(self.vrmModel.fieldIndex('PermitTypeID')),
                                      QSqlRelation('PermitTypes', 'Code', 'Description'))
            self.vrmModel.setRelation(int(self.vrmModel.fieldIndex("InternationalCodeID")),
                                      QSqlRelation('InternationalCodes', 'Code',
                                                   'Description'))
            self.vrmModel.setRelation(int(self.vrmModel.fieldIndex('ParkingActivityTypeID')),
                                      QSqlRelation('ParkingActivityTypes', 'Code', 'Description'))
            self.vrmModel.setRelation(int(self.vrmModel.fieldIndex('ParkingMannerTypeID')),
                                      QSqlRelation('ParkingMannerTypes', 'Code', 'Description'))

        # Vehicle types
        rel = self.vrmModel.relation(int(self.vrmModel.fieldIndex('VehicleTypeID')))
        if not rel.isValid():
            #print ('Relation not valid ...')
            TOMsMessageLog.logMessage("In populateDemandWidget: Relation not valid ... {} ".format(self.vrmModel.lastError().text()),
                                      level=Qgis.Warning)
        self.vrmModel.setHeaderData(self.vrmModel.fieldIndex('VehicleTypeID'), Qt.Horizontal, 'VehicleTypeID')

        # Permit types
        rel = self.vrmModel.relation(int(self.vrmModel.fieldIndex('PermitTypeID')))
        if not rel.isValid():
            #print ('Relation not valid ...')
            TOMsMessageLog.logMessage("In populateDemandWidget: Relation not valid ... {} ".format(self.vrmModel.lastError().text()),
                                      level=Qgis.Warning)
        self.vrmModel.setHeaderData(self.vrmModel.fieldIndex('PermitTypeID'), Qt.Horizontal, 'PermitTypeID')

        # International codes
        rel = self.vrmModel.relation(int(self.vrmModel.fieldIndex('InternationalCodeID')))
        if not rel.isValid():
            #print ('Relation not valid ...')
            TOMsMessageLog.logMessage("In populateDemandWidget: Relation not valid ... {} ".format(self.vrmModel.lastError().text()),
                                      level=Qgis.Warning)
        self.vrmModel.setHeaderData(self.vrmModel.fieldIndex('InternationalCodeID'), Qt.Horizontal, 'InternationalCodeID')

        # Parking Activity types
        rel = self.vrmModel.relation(int(self.vrmModel.fieldIndex('ParkingActivityTypeID')))
        if not rel.isValid():
            #print ('Relation not valid ...')
            TOMsMessageLog.logMessage("In populateDemandWidget: Relation not valid ... {} ".format(self.vrmModel.lastError().text()),
                                      level=Qgis.Warning)
        self.vrmModel.setHeaderData(self.vrmModel.fieldIndex('ParkingActivityTypeID'), Qt.Horizontal, 'ParkingActivityTypeID')

        # Parking Manner types
        rel = self.vrmModel.relation(int(self.vrmModel.fieldIndex('ParkingMannerTypeID')))
        if not rel.isValid():
            #print ('Relation not valid ...')
            TOMsMessageLog.logMessage("In populateDemandWidget: Relation not valid ... {} ".format(self.vrmModel.lastError().text()),
                                      level=Qgis.Warning)
        self.vrmModel.setHeaderData(self.vrmModel.fieldIndex('ParkingMannerTypeID'), Qt.Horizontal, 'ParkingMannerTypeID')

        result = self.vrmModel.select()
        if result == False:
            TOMsMessageLog.logMessage("In populateDemandWidget: No result from select: {} ".format(self.vrmModel.lastError().text()),
                                      level=Qgis.Warning)

        TOMsMessageLog.logMessage(
            "In populateDemandWidget: nr Rows: {} ".format(self.vrmModel.rowCount()),
            level=Qgis.Warning)

        self.setModel(self.vrmModel)

        # TODO: check to see which fields are required ...

        # read required fields from config file

        for i in range(self.vrmModel.columnCount()):
            currFieldName = str(self.vrmModel.headerData(i, Qt.Horizontal, Qt.DisplayRole))
            TOMsMessageLog.logMessage("In populateDemandWidget: Considering {} ...".format(currFieldName), level=Qgis.Warning)

            found = False

            for thisField in demandFields:
                details = thisField.split(":")
                TOMsMessageLog.logMessage("In populateDemandWidget: field: {} ...".format(details[0]),
                                          level=Qgis.Warning)

                if details[0] == currFieldName:
                    # check for new name
                    found = True
                    TOMsMessageLog.logMessage("In populateDemandWidget: field found", level=Qgis.Warning)
                    if len(details) > 1:
                        self.vrmModel.setHeaderData(i, Qt.Horizontal, details[1])
                    break

            if not found:
                TOMsMessageLog.logMessage("In populateDemandWidget: {} field not found. Hiding".format(currFieldName), level=Qgis.Warning)

                try:
                    self.setColumnHidden(self.vrmModel.fieldIndex(currFieldName), True)  # fid not present within postgres
                    #self.vrmModel.removeColumns(self.vrmModel.fieldIndex(currFieldName), 1, self.vrmModel.fieldIndex(currFieldName))  # fid not present within postgres
                except Exception as e:
                    # QMessageBox.information(self.iface.mainWindow(), "ERROR", ("Error opening test layer {}".format(e)))
                    TOMsMessageLog.logMessage("In populateDemandWidget: error {}".format(e), level=Qgis.Warning)
                    #pass

        #self.setColumnHidden(self.vrmModel.fieldIndex('ID'), True)
        #self.setColumnHidden(self.vrmModel.fieldIndex('SurveyID'), True)

        ###self.setColumnHidden(self.vrmModel.fieldIndex('SectionID'), True)

        #self.setColumnHidden(self.vrmModel.fieldIndex('GeometryID'), True)

        ###self.setColumnHidden(self.vrmModel.fieldIndex('RestrictionTypeID'), True)

        self.verticalHeader().hide()
        self.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeToContents)
        self.setItemDelegate(QSqlRelationalDelegate(self.vrmModel))
        self.setItemDelegateForColumn(self.vrmModel.fieldIndex("PositionID"), readOnlyDelegate(self));
        self.setItemDelegateForColumn(self.vrmModel.fieldIndex("VRM"), vrmDelegate(self));
        #self.setItemDelegateForColumn(self.vrmModel.fieldIndex("Foreign"), CheckBoxDelegate(self));  # Need to find way to include check box delegate

        self.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn)
        self.resizeColumnsToContents()
        self.setColumnWidth(self.vrmModel.fieldIndex("VRM"), 120)

    def insertVrm(self, surveyID, GeometryID):
        TOMsMessageLog.logMessage("In vrmWidget:insertRow ... surveyID: {}; GeometryID: {}".format(surveyID, GeometryID), level=Qgis.Info)

        rowCount = self.vrmModel.rowCount()
        index = self.currentIndex()   # 0-based

        if not index.isValid():  # typically this is for no rows being present ...
            currRow = 0
        else:
            currRow = index.row()

        TOMsMessageLog.logMessage("In vrmWidget:insertRow ... row: {}; index:{}".format(rowCount, currRow), level=Qgis.Info)

        # add new record at position
        record = self.vrmModel.record()
        if self.dbConn.driverName() == 'QPSQL':
            record.setGenerated('ID', False)
        else:
            record.setGenerated('fid', False)

        #record.setGenerated('fid', False)

        record.setValue('SurveyID', surveyID)
        record.setValue('SectionID', None)
        record.setValue('GeometryID', GeometryID)


        TOMsMessageLog.logMessage("Record - surveyID: {}".format(record.value(record.indexOf("SurveyID"))),
                                      level=Qgis.Info)

        if currRow == 0 and rowCount == 0:
            record.setValue('PositionID', currRow + 1)
            res = self.vrmModel.insertRecord(currRow, record)
        else:
            record.setValue('PositionID', currRow + 2)
            res = self.vrmModel.insertRecord(currRow+1, record)

        TOMsMessageLog.logMessage("Record - insert: {}".format(res),
                                      level=Qgis.Info)
        if not res:
            TOMsMessageLog.logMessage("In insertVrm: issue with insert ... {} ".format(self.vrmModel.lastError().text()),
                                      level=Qgis.Warning)

        # re-order positions
        extent = (self.vrmModel.rowCount()+2) - (currRow+2)
        self.startOperation.emit()
        for i in range (currRow+2, self.vrmModel.rowCount()+2):
            TOMsMessageLog.logMessage("In insertVrm: changing positions ... {} ".format(i),
                                      level=Qgis.Info)
            self.vrmModel.setData(QModelIndex(self.vrmModel.index(i, self.vrmModel.fieldIndex('PositionID'))), i+1)
            percentComplete = int((i-currRow+2) / float(extent) * 100)
            self.progressUpdated.emit(percentComplete)
            #self.iface.statusBarIface().showMessage("Processed {} %".format(int(percentComplete)))

        #self.iface.statusBarIface().clearMessage()
        self.endOperation.emit()

        self.vrmModel.select()


    def deleteVrm(self):
        TOMsMessageLog.logMessage("In vrmWidget:deleteRow ... ", level=Qgis.Info)

        index = self.currentIndex()

        if not index.isValid():  # typically this is for no rows being present ...
            currRow = 0
        else:
            currRow = index.row()

        self.vrmModel.removeRow(currRow)

        # re-order positions
        extent = (self.vrmModel.rowCount() + 2) - (currRow + 1)
        self.startOperation.emit()
        for i in range (currRow+1, self.vrmModel.rowCount()+2):
            TOMsMessageLog.logMessage("In insertVrm: changing positions ... {} ".format(i),
                                      level=Qgis.Info)
            self.vrmModel.setData(QModelIndex(self.vrmModel.index(i, self.vrmModel.fieldIndex('PositionID'))), i)
            percentComplete = (i-currRow+1) / float(extent) * 100
            self.progressUpdated.emit(percentComplete)
            #self.iface.statusBarIface().showMessage("Processed {} %".format(int(percentComplete)))

        #self.iface.statusBarIface().clearMessage()
        self.endOperation.emit()

        self.vrmModel.submitAll()
        self.vrmModel.select()

# https://stackoverflow.com/questions/24024815/set-a-whole-column-in-qtablewidget-read-only-in-python
class readOnlyDelegate(QItemDelegate):

    def createEditor(self, *args):
        return None

class vrmDelegate(QStyledItemDelegate):
    def createEditor(self, parent, option, index):
        editor = super().createEditor(parent, option, index)
        if isinstance(editor, QLineEdit):
            editor.setInputMask('>nnnn-nnnn')
        return editor