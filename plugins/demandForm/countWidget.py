""" ***


*** """
from qgis.PyQt.QtCore import (
    QObject,
    QTimer,
    QThread,
    pyqtSignal,
    pyqtSlot, Qt, QModelIndex
)

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
    QProgressDialog, QProgressBar, QTextEdit, QTabWidget, QPlainTextEdit
)

from qgis.PyQt.QtSql import (
    QSqlDatabase, QSqlQuery, QSqlQueryModel, QSqlRelation, QSqlRelationalTableModel, QSqlRelationalDelegate, QSqlTableModel
)

from qgis.PyQt.QtGui import (
    QIntValidator, QIcon,
    QPixmap,
    QImage, QPainter
)

from qgis.core import (
    Qgis,
    QgsFeatureRequest,
    QgsProject
)

from TOMs.core.TOMsMessageLog import TOMsMessageLog

class countWidget(QWidget):

    progressUpdated = pyqtSignal(int)
    startOperation = pyqtSignal()
    endOperation = pyqtSignal()

    def __init__(self, dbConn, demand_schema, currSurveyID, currRestriction):
        super(countWidget, self).__init__()
        TOMsMessageLog.logMessage("In countWidget:init ... ", level=Qgis.Info)
        self.dbConn = dbConn
        self.demand_schema = demand_schema
        self.countModel = QSqlRelationalTableModel(self, db=self.dbConn)
        #self.restrictionDialog = QWidget()
        self.currSurveyID = currSurveyID
        self.currRestriction = currRestriction
        self.currGeometryID = self.currRestriction.attribute("GeometryID")

    def getCountModel(self):
        return self.countModel

    def setupUi(self, extraTabLabel=None):

        TOMsMessageLog.logMessage("In countWidget:setupUi ... surveyID: {}; GeometryID: {}; extraTabLabel: {}".format(self.currSurveyID, self.currGeometryID, extraTabLabel), level=Qgis.Info)

        if self.dbConn.driverName() == 'QPSQL':
            table = '"{}"."Counts"'.format(self.demand_schema)
            self.countModel.setTable(table)
            #self.countModel.setTable('demand' + '.\"Counts\"')
        else:
            self.countModel.setTable('Counts')

        filterString = "\"SurveyID\" = {} AND \"GeometryID\" = \'{}\'".format(self.currSurveyID, self.currGeometryID)
        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... filterString: {}".format(filterString),
                                  level=Qgis.Info)

        #self.countModel.setFilter(filterString)

        self.mapper = QDataWidgetMapper(self)
        self.mapper.setModel(self.countModel)

        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... model set ...",
                                  level=Qgis.Info)
        self.setupMainCountTab()

        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... checking for extraTab ...",
                                  level=Qgis.Info)

        if extraTabLabel is not None:
            """ TODO: need to rethink this """
            TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ...adding extraTab  ...",
                                  level=Qgis.Info)
            extraTab = self.setupExtraCountTab()
            TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... new tab added ...",
                                      level=Qgis.Warning)
            demandTab = self.restrictionDialog.findChild(QTabWidget, "Details")
            demandTab.insertTab(1, extraTab, extraTabLabel)  # 0 based index
            self.setupExtraCountTabMapping()

        """
        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... about to select ...",
                                  level=Qgis.Info)

        result = self.countModel.select()
        if result == False:
            TOMsMessageLog.logMessage(
                "In populateDemandWidget: No result from select: {} ".format(self.countModel.lastError().text()),
                level=Qgis.Info)

        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... selected ...",
                                  level=Qgis.Info)

        TOMsMessageLog.logMessage(
            "In populateDemandWidget: nr Rows: {} ".format(self.countModel.rowCount()),
            level=Qgis.Info)

        self.mapper.toFirst()  # TODO: check if this fails ...
        """
        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... finishing ...",
                                  level=Qgis.Info)

    def setupMainCountTab(self):

        TOMsMessageLog.logMessage("In countWidget:setupMainCountTab ... ",
                                  level=Qgis.Info)

        #demandTab = self.restrictionDialog.findChild(QWidget, "Demand")
        #demandLayout = demandTab.layout()
        demandLayout = QGridLayout(self)

        countLayout = QHBoxLayout()
        col1_layout = QFormLayout()
        col2_layout = QFormLayout()
        col3_layout = QFormLayout()
        col4_layout = QFormLayout()

        # spacerItem = QSpacerItem(0, 0, QSizePolicy.Expanding, QSizePolicy.Minimum)

        col1_layout.addRow(QLabel(""), QLabel("Parked"))
        col1_layout.addRow(QLabel("Cars:"), QLineEdit(objectName='NrCars'))
        col1_layout.addRow(QLabel("LGVs:"), QLineEdit(objectName='NrLGVs'))
        col1_layout.addRow(QLabel("MCLs:"), QLineEdit(objectName='NrMCLs'))
        col1_layout.addRow(QLabel("Taxis:"), QLineEdit(objectName='NrTaxis'))
        col1_layout.addRow(QLabel("OGVs:"), QLineEdit(objectName='NrOGVs'))
        col1_layout.addRow(QLabel("Mini Buses:"), QLineEdit(objectName='NrMiniBuses'))
        col1_layout.addRow(QLabel("Buses:"), QLineEdit(objectName='NrBuses'))

        col2_layout.addRow(QLabel("Waiting"))
        col2_layout.addRow(QLineEdit(objectName='NrCarsWaiting'))
        col2_layout.addRow(QLineEdit(objectName='NrLGVsWaiting'))
        col2_layout.addRow(QLineEdit(objectName='NrMCLsWaiting'))
        col2_layout.addRow(QLineEdit(objectName='NrTaxisWaiting'))
        col2_layout.addRow(QLineEdit(objectName='NrOGVsWaiting'))
        col2_layout.addRow(QLineEdit(objectName='NrMiniBusesWaiting'))
        col2_layout.addRow(QLineEdit(objectName='NrBusesWaiting'))

        col3_layout.addRow(QLabel("Idling"))
        col3_layout.addRow(QLineEdit(objectName='NrCarsIdling'))
        col3_layout.addRow(QLineEdit(objectName='NrLGVsIdling'))
        col3_layout.addRow(QLineEdit(objectName='NrMCLsIdling'))
        col3_layout.addRow(QLineEdit(objectName='NrTaxisIdling'))
        col3_layout.addRow(QLineEdit(objectName='NrOGVsIdling'))
        col3_layout.addRow(QLineEdit(objectName='NrMiniBusesIdling'))
        col3_layout.addRow(QLineEdit(objectName='NrBusesIdling'))

        col4_layout.addRow(QLabel(""))
        col4_layout.addRow(QLabel("PCLs:"), QLineEdit(objectName='NrPCLs'))
        col4_layout.addRow("E-Scooters:", QLineEdit(objectName='NrEScooters'))
        col4_layout.addRow("Dockless PCLs:", QLineEdit(objectName='NrDocklessPCLs'))

        col4_layout.addRow(QLabel(""))
        col4_layout.addRow("Spaces:", QLineEdit(objectName='NrSpaces'))

        countLayout.addLayout(col1_layout)
        countLayout.addLayout(col2_layout)
        countLayout.addLayout(col3_layout)

        if self.payByPhoneBay():
            # add extra details to layout
            col5_layout = QFormLayout()
            col5_layout.addRow(QLabel("Disabled Badges"))
            col5_layout.addRow(QLineEdit(objectName='NrCarsWithDisabledBadgeParkedInPandD'))
            countLayout.addLayout(col5_layout)

        countLayout.addLayout(col4_layout)

        TOMsMessageLog.logMessage("In countWidget:setupMainCountTab. Finished adding bits ... ",
                                  level=Qgis.Info)

        # Now add "Notes" widget
        notes_layout = QFormLayout()
        demandNotes = QPlainTextEdit(objectName='Notes')
        # demandNotes.setPlainText()
        notes_layout.addRow("Notes:", demandNotes)

        demandLayout.addLayout(countLayout, 0, 0)

        demandLayout.addLayout(notes_layout, 2, 0)

        # add validators
        # use of validator - https://stackoverflow.com/questions/54741145/i-use-qdoublevalidator-in-my-pyqt5-program-but-it-doesnt-seem-to-work

        TOMsMessageLog.logMessage("In countWidget:setupMainCountTab. Finished layouts ... ",
                                  level=Qgis.Info)

        validator = QIntValidator(0, 99)
        for widget in countLayout.parentWidget().findChildren(QLineEdit):
            widget.setValidator(validator)
            # TO DO: need to set yp slot fucntion to validate based on changed() signal
            widget.textChanged.connect(lambda: self.doIntValidation(widget))
            TOMsMessageLog.logMessage("In countWidget:setupMainCountTab. setting validator for ... {}".format(widget.objectName()),
                                      level=Qgis.Info)

        TOMsMessageLog.logMessage("In countWidget:setupMainCountTab. Starting mapping ... ",
                                  level=Qgis.Info)

        try:
            self.mapper.addMapping(self.findChild(QLineEdit, "NrCars"),
                                   self.countModel.fieldIndex('NrCars'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrCarsIdling"),
                                   self.countModel.fieldIndex('NrCarsIdling'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrCarsWaiting"),
                                   self.countModel.fieldIndex('NrCarsWaiting'))

            self.mapper.addMapping(self.findChild(QLineEdit, "NrLGVs"),
                                   self.countModel.fieldIndex('NrLGVs'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrLGVsIdling"),
                                   self.countModel.fieldIndex('NrLGVsIdling'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrLGVsWaiting"),
                                   self.countModel.fieldIndex('NrLGVsWaiting'))

            self.mapper.addMapping(self.findChild(QLineEdit, "NrMCLs"),
                                   self.countModel.fieldIndex('NrMCLs'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrMCLsIdling"),
                                   self.countModel.fieldIndex('NrMCLsIdling'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrMCLsWaiting"),
                                   self.countModel.fieldIndex('NrMCLsWaiting'))

            self.mapper.addMapping(self.findChild(QLineEdit, "NrTaxis"),
                                   self.countModel.fieldIndex('NrTaxis'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrTaxisIdling"),
                                   self.countModel.fieldIndex('NrTaxisIdling'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrTaxisWaiting"),
                                   self.countModel.fieldIndex('NrTaxisWaiting'))

            self.mapper.addMapping(self.findChild(QLineEdit, "NrOGVs"),
                                   self.countModel.fieldIndex('NrOGVs'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrOGVsIdling"),
                                   self.countModel.fieldIndex('NrOGVsIdling'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrOGVsWaiting"),
                                   self.countModel.fieldIndex('NrOGVsWaiting'))

            self.mapper.addMapping(self.findChild(QLineEdit, "NrMiniBuses"),
                                   self.countModel.fieldIndex('NrMiniBuses'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrMiniBusesIdling"),
                                   self.countModel.fieldIndex('NrMiniBusesIdling'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrMiniBusesWaiting"),
                                   self.countModel.fieldIndex('NrMiniBusesWaiting'))

            self.mapper.addMapping(self.findChild(QLineEdit, "NrBuses"),
                                   self.countModel.fieldIndex('NrBuses'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrBusesIdling"),
                                   self.countModel.fieldIndex('NrBusesIdling'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrBusesWaiting"),
                                   self.countModel.fieldIndex('NrBusesWaiting'))

            self.mapper.addMapping(self.findChild(QLineEdit, "NrPCLs"),
                                   self.countModel.fieldIndex('NrPCLs'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrEScooters"),
                                   self.countModel.fieldIndex('NrEScooters'))
            self.mapper.addMapping(self.findChild(QLineEdit, "NrDocklessPCLs"),
                                   self.countModel.fieldIndex('NrDocklessPCLs'))

            self.mapper.addMapping(self.findChild(QLineEdit, "NrSpaces"),
                                   self.countModel.fieldIndex('NrSpaces'))
            self.mapper.addMapping(self.findChild(QPlainTextEdit, "Notes"),
                                   self.countModel.fieldIndex('Notes'))

            if self.payByPhoneBay():
                self.mapper.addMapping(
                    self.findChild(QLineEdit, "NrCarsWithDisabledBadgeParkedInPandD"),
                    self.countModel.fieldIndex('NrCarsWithDisabledBadgeParkedInPandD'))

        except Exception as e:
            TOMsMessageLog.logMessage('countWidget:setupMainCountTab. Error with mapping: {}'.format(e),
                                      level=Qgis.Warning)
            return

        TOMsMessageLog.logMessage("In countWidget:setupMainCountTab ... mapping added ...",
                                  level=Qgis.Info)

    def doIntValidation(self, widget):
        TOMsMessageLog.logMessage(
            "In countWidget:doIntValidation. ** validating for ... {}".format(widget.objectName()),
            level=Qgis.Info)
        status = widget

    def payByPhoneBay(self):
        # check to see if this is a P&D bay

        TOMsMessageLog.logMessage('countWidget:payByPhoneBay. ...',
                                  level=Qgis.Info)

        supplyLayer = QgsProject.instance().mapLayersByName('Supply')[0]


        query = "\"GeometryID\" = '{}'".format(self.currRestriction.attribute("GeometryID"))
        TOMsMessageLog.logMessage('countWidget:payByPhoneBay. query: {}'.format(query),
                                  level=Qgis.Info)
        request = QgsFeatureRequest().setFilterExpression(query)

        # QgsMessageLog.logMessage("In getLookupLabelText. queryStatus: " + str(query), tag="TOMs panel")
        currRestrictionTypeID = 0

        try:

            for row in supplyLayer.getFeatures(request):
                # QgsMessageLog.logMessage("In getLookupLabelText: found row " + str(row.attribute("LabelText")), tag="TOMs panel")
                currRestrictionTypeID = row.attribute("RestrictionTypeID")  # make assumption that only one row
                TOMsMessageLog.logMessage('countWidget:payByPhoneBay. RestrictionTypeID found: {}'.format(currRestrictionTypeID),
                                      level=Qgis.Info)
                break

            if int(currRestrictionTypeID) == 103:
                return True

        except Exception as e:
            TOMsMessageLog.logMessage('countWidget:payByPhoneBay. Error: {}'.format(e),
                                      level=Qgis.Warning)
            return False

    def setupExtraCountTab(self):

        TOMsMessageLog.logMessage("In countWidget:setupExtraCountTab ... starting ...",
                                  level=Qgis.Info)

        extraTab = QWidget()
        demandLayout = QGridLayout(extraTab)

        countLayout = QHBoxLayout()
        col1_layout = QFormLayout()
        col2_layout = QFormLayout()

        #spacerItem = QSpacerItem(0, 0, QSizePolicy.Expanding, QSizePolicy.Minimum)

        col1_layout.addRow("Cars on YL:", QLineEdit(objectName='NrCars_Suspended'))
        col1_layout.addRow("LGVs on YL:", QLineEdit(objectName='NrLGVs_Suspended'))
        col1_layout.addRow("MCLs on YL:", QLineEdit(objectName='NrMCLs_Suspended'))
        col1_layout.addRow("Taxis on YL:", QLineEdit(objectName='NrTaxis_Suspended'))
        col1_layout.addRow("OGVs on YL:", QLineEdit(objectName='NrOGVs_Suspended'))
        col1_layout.addRow("Mini Buses on YL:", QLineEdit(objectName='NrMiniBuses_Suspended'))

        col2_layout.addRow("PCLs on YL:", QLineEdit(objectName='NrPCLs_Suspended'))
        col2_layout.addRow("E-Scooters on YL:", QLineEdit(objectName='NrEScooters_Suspended'))
        col2_layout.addRow("Dockless PCLs on YL:", QLineEdit(objectName='NrDocklessPCLs_Suspended'))
        col2_layout.addRow("Buses on YL:", QLineEdit(objectName='NrBuses_Suspended'))

        countLayout.addLayout(col1_layout)
        verticalSpacer = QSpacerItem(10, 40, QSizePolicy.Minimum, QSizePolicy.Expanding)
        countLayout.addItem(verticalSpacer)
        countLayout.addLayout(col2_layout)

        demandLayout.addLayout(countLayout, 0, 0)

        # add validators
        # use of validator - https://stackoverflow.com/questions/54741145/i-use-qdoublevalidator-in-my-pyqt5-program-but-it-doesnt-seem-to-work

        for widget in countLayout.parentWidget().findChildren(QLineEdit):
            widget.setValidator(QIntValidator(
                0,  # bottom
                99  # top
            ))
            widget.textChanged.connect(lambda: self.doIntValidation(widget))

        TOMsMessageLog.logMessage("In countWidget:setupExtraCountTab ... finishing ...",
                                  level=Qgis.Info)

        return extraTab

    def setupExtraCountTabMapping(self):

        TOMsMessageLog.logMessage("In countWidget:setupExtraCountTabMapping ... starting ...",
                                  level=Qgis.Info)

        self.mapper.addMapping(self.findChild(QLineEdit, "NrCars_Suspended"),
                               self.countModel.fieldIndex('NrCars_Suspended'))
        self.mapper.addMapping(self.findChild(QLineEdit, "NrLGVs_Suspended"),
                               self.countModel.fieldIndex('NrLGVs_Suspended'))
        self.mapper.addMapping(self.findChild(QLineEdit, "NrMCLs_Suspended"),
                               self.countModel.fieldIndex('NrMCLs_Suspended'))
        self.mapper.addMapping(self.findChild(QLineEdit, "NrTaxis_Suspended"),
                               self.countModel.fieldIndex('NrTaxis_Suspended'))
        self.mapper.addMapping(self.findChild(QLineEdit, "NrPCLs_Suspended"),
                               self.countModel.fieldIndex('NrPCLs_Suspended'))
        self.mapper.addMapping(self.findChild(QLineEdit, "NrEScooters_Suspended"),
                               self.countModel.fieldIndex('NrEScooters_Suspended'))
        self.mapper.addMapping(self.findChild(QLineEdit, "NrDocklessPCLs_Suspended"),
                               self.countModel.fieldIndex('NrDocklessPCLs_Suspended'))
        self.mapper.addMapping(self.findChild(QLineEdit, "NrOGVs_Suspended"),
                               self.countModel.fieldIndex('NrOGVs_Suspended'))
        self.mapper.addMapping(self.findChild(QLineEdit, "NrMiniBuses_Suspended"),
                               self.countModel.fieldIndex('NrMiniBuses_Suspended'))
        self.mapper.addMapping(self.findChild(QLineEdit, "NrBuses_Suspended"),
                               self.countModel.fieldIndex('NrBuses_Suspended'))

        TOMsMessageLog.logMessage("In countWidget:setupExtraCountTab ... mapping added ...",
                                  level=Qgis.Info)

    def populateDemandWidget(self, extraTabLabel=None):

        #TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... surveyID: {}; GeometryID: {}; extraTabLabel: {}".format(self.currSurveyID, self.currGeometryID, extraTabLabel), level=Qgis.Info)

        """
        if self.dbConn.driverName() == 'QPSQL':
            table = '"{}"."Counts"'.format(self.demand_schema)
            self.countModel.setTable(table)
            #self.countModel.setTable('demand' + '.\"Counts\"')
        else:
            self.countModel.setTable('Counts')
        """

        filterString = "\"SurveyID\" = {} AND \"GeometryID\" = \'{}\'".format(self.currSurveyID, self.currGeometryID)
        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... filterString: {}".format(filterString),
                                  level=Qgis.Info)

        self.countModel.setFilter(filterString)

        """
        self.mapper = QDataWidgetMapper(self)
        self.mapper.setModel(self.countModel)

        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... model set ...",
                                  level=Qgis.Info)
        self.setupMainCountTab()

        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... checking for extraTab ...",
                                  level=Qgis.Info)

        
        if extraTabLabel is not None:
            # TODO: need to rethink this
            TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ...adding extraTab  ...",
                                  level=Qgis.Info)
            extraTab = self.setupExtraCountTab()
            TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... new tab added ...",
                                      level=Qgis.Warning)
            demandTab = self.restrictionDialog.findChild(QTabWidget, "Details")
            demandTab.insertTab(1, extraTab, extraTabLabel)  # 0 based index
            self.setupExtraCountTabMapping()
        """

        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... about to select ...",
                                  level=Qgis.Info)

        result = self.countModel.select()
        if result == False:
            TOMsMessageLog.logMessage(
                "In populateDemandWidget: No result from select: {} ".format(self.countModel.lastError().text()),
                level=Qgis.Info)

        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... selected ...",
                                  level=Qgis.Info)

        TOMsMessageLog.logMessage(
            "In populateDemandWidget: nr Rows: {} ".format(self.countModel.rowCount()),
            level=Qgis.Info)

        # TODO: Action if no rows returned ...

        self.mapper.toFirst()  # TODO: check if this fails ...

        TOMsMessageLog.logMessage("In countWidget:populateDemandWidget ... finishing ...",
                                  level=Qgis.Info)

