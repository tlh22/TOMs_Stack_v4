# Using model/view for demand VRM form

#----- trials
# https://stackoverflow.com/questions/49752388/editable-qtableview-of-complex-sql-query

# setup relational model
# https://stackoverflow.com/questions/51962262/pyqt-add-new-record-using-qsqlrelationaltablemodel-and-qtableview
# https://stackoverflow.com/questions/18716637/how-to-filter-qsqlrelationaltablemodel-with-pyqt
# https://stackoverflow.com/questions/54299754/pyqt5-qsqlrelationaltablemodel-populate-data-with-sqlalchemy-model
# https://gist.github.com/harvimt/4699169
# https://deptinfo-ensip.univ-poitiers.fr/ENS/pyside-docs/PySide/QtSql/QSqlRelationalTableModel.html?highlight=relational

from qgis.PyQt.QtCore import (
    Qt
)
from qgis.PyQt.QtWidgets import (
QMessageBox, QWidget, QTableView, QVBoxLayout, QMainWindow,
QMdiArea, QMdiSubWindow, QApplication
)
from qgis.PyQt.QtSql import (
    QSqlDatabase, QSqlQuery, QSqlQueryModel, QSqlRelation, QSqlRelationalTableModel, QSqlRelationalDelegate
)

from qgis.core import (
    Qgis,
    QgsExpressionContextUtils,
    QgsProject,
    QgsMessageLog,
    QgsFeature,
    QgsGeometry, QgsGeometryUtils,
    QgsApplication, QgsCoordinateTransform, QgsCoordinateReferenceSystem,
    QgsGpsDetector, QgsGpsConnection, QgsGpsInformation, QgsPoint, QgsPointXY,
    QgsDataSourceUri, QgsRectangle, QgsFeatureRequest, QgsWkbTypes
)

from qgis.gui import (
    QgsVertexMarker,
    QgsMapToolEmitPoint, QgsRubberBand
)

from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction,
    QDialogButtonBox,
    QLabel, QTabWidget,
    QDockWidget,
    QWidget,
    QHBoxLayout, QComboBox, QGroupBox, QFormLayout, QStackedWidget, QPushButton, QLineEdit
)

from .ui.VRM_Demand_dialog import VRM_DemandDialog
from TOMs.core.TOMsMessageLog import TOMsMessageLog
import os, uuid

def createConnection():
    con = QSqlDatabase.addDatabase("QSQLITE")
    #
    #photoPath = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('DemandGpkg')
    #projectFolder = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('project_folder')
    #
    #path_absolute = os.path.join(projectFolder, photoPath)
    #
    #if path_absolute == None:
    #    reply = QMessageBox.information(None, "Information", "Please set value for Demand Gpkg.", QMessageBox.Ok)
    #    return
    #
    #con.setDatabaseName("C:\\Users\\marie_000\\Documents\\MHTC\\VRM_Test.gpkg")
    con.setDatabaseName("Z:\\Tim\\SYS20-12 Zone K, Watford\\Test\\Mapping\\Geopackages\\SYS2012_Demand_VRMs.gpkg")
    #con.setDatabaseName(path_absolute)
    # "Z:\\Tim\\SYS20-12 Zone K, Watford\\Test\\Mapping\\Geopackages\\SYS2012_Demand.gpkg"
    if not con.open():
        QMessageBox.critical(None, "Cannot open memory database",
                             "Unable to establish a database connection.\n\n"
                             "Click Cancel to exit.", QMessageBox.Cancel)
        return False
    #
    TOMsMessageLog.logMessage("In createConnection: db name: {} ".format(con.databaseName()),
                              level=Qgis.Warning)
    #query = QtSql.QSqlQuery()
    return True

class vrmWidget(QWidget):
    def __init__(self, parent=None):
        super(vrmWidget, self).__init__(parent)
        # this layout_box can be used if you need more widgets
        # I used just one named WebsitesWidget
        #layout_box = QVBoxLayout(self)
        #
        #vrmView = QTableView()
        # put view in layout_box area
        #layout_box.addWidget(vrmView)
        # create a table model
        """
        my_model = SqlQueryModel()
        q = QSqlQuery(query)
        my_model.setQuery(q)
        my_model.setFilter("SurveyID = 1 AND SectionID = 5")
        my_model.select()
        my_view.setModel(my_model)
        """

        #q = QSqlQuery()
        #result = q.prepare("SELECT PositionID, VRM, VehicleTypeID, RestrictionTypeID, PermitType, Notes FROM VRMs")
        #if result == False:
        #    print ('Prepare: {}'.format(q.lastError().text()))
        #my_model.setQuery(q)

        """
        result = my_model.select()
        if result == False:
            TOMsMessageLog.logMessage("In testWidget: No result: {} ".format(my_model.lastError().text()),
                                      level=Qgis.Warning)
            #print ('Select: {}'.format(my_model.lastError().text()))
        #show the view with model
        my_view.setModel(my_model)
        my_view.setColumnHidden(my_model.fieldIndex('fid'), True)
        my_view.setColumnHidden(my_model.fieldIndex('ID'), True)
        my_view.setColumnHidden(my_model.fieldIndex('SurveyID'), True)
        my_view.setColumnHidden(my_model.fieldIndex('SectionID'), True)
        my_view.setColumnHidden(my_model.fieldIndex('GeometryID'), True)
        my_view.setItemDelegate(QSqlRelationalDelegate(my_view))
        """

    def createLayoutForFeature(self, surveyID, GeometryID):

        # keep pks
        self.surveyID = surveyID
        self.GeometryID = GeometryID

        layout_box = QVBoxLayout(self)
        #
        vrmView = QTableView()

        vrmModel = QSqlRelationalTableModel(self)
        vrmModel.setTable("VRMs")

        filterString = "SurveyID = {} AND SectionID = {}".format(surveyID, GeometryID)
        vrmModel.setFilter(filterString)
        #vrmModel.setFilter("SurveyID = 1 AND SectionID = 5")
        vrmModel.setSort(int(vrmModel.fieldIndex("PositionID")), Qt.AscendingOrder)
        vrmModel.setRelation(int(vrmModel.fieldIndex("VehicleTypeID")), QSqlRelation('VehicleTypes', 'Code', 'Description'))
        rel = vrmModel.relation(int(vrmModel.fieldIndex("VehicleTypeID")))
        if not rel.isValid():
            print ('Relation not valid ...')
            TOMsMessageLog.logMessage("In testWidget: Relation not valid ... {} ".format(vrmModel.lastError().text()),
                                      level=Qgis.Warning)

        result = vrmModel.select()
        if result == False:
            TOMsMessageLog.logMessage("In testWidget: No result: {} ".format(vrmModel.lastError().text()),
                                      level=Qgis.Warning)
            #print ('Select: {}'.format(my_model.lastError().text()))
        #show the view with model
        vrmView.setModel(vrmModel)
        vrmView.setColumnHidden(vrmModel.fieldIndex('fid'), True)
        vrmView.setColumnHidden(vrmModel.fieldIndex('ID'), True)
        vrmView.setColumnHidden(vrmModel.fieldIndex('SurveyID'), True)
        vrmView.setColumnHidden(vrmModel.fieldIndex('SectionID'), True)
        vrmView.setColumnHidden(vrmModel.fieldIndex('GeometryID'), True)
        vrmView.setItemDelegate(QSqlRelationalDelegate(vrmModel))

        self.vrmView = vrmView
        self.vrmModel = vrmModel

        # put view in layout_box area
        layout_box.addWidget(vrmView)

        return layout_box

    def insertRow(self):
        print ("Inserting row ...")

        row = self.vrmModel.rowCount()
        record = self.vrmModel.record()
        #record.setGenerated('id', False)
        record.setValue('SurveyID', self.surveyID)
        record.setValue('GeometryID', self.GeometryID)
        #record.setValue('department', self.ui.department.currentText())

        #record.setValue('starttime', QDateTime.currentDateTime())
        #record.setValue('endtime', QDateTime.currentDateTime())

        self.vrmModel.insertRecord(row, record)
        #self.vrmModel.edit(QModelIndex(self.vrmModel.index(row, self.hours_model.fieldIndex('department'))))

    def deleteRow(self):
        pass

class VRM_DemandForm(VRM_DemandDialog):
    def __init__(self, iface, parent=None):
        if not parent:
            parent = iface.mainWindow()
        super().__init__(parent)
        self.iface = iface
        QgsMessageLog.logMessage("In VRM_DemandForm::init", tag="TOMs panel")
        #self.setupThisUi(parent)
    def setupThisUi(self, parent):

        vrmsTab = self.demandDialog.findChild(QWidget, "VRMs")
        vrmsLayout = vrmsTab.layout()
        vrmForm = vrmWidget(vrmsTab)
        vrmsLayout.addWidget(vrmForm)



        # set up connections

        #grid = detailsTab.layout()
        #print (grid)
        #grid.addWidget(vrmForm)
        #grid.addWidget(vrmForm, 0, 0, 1, 1)


        # add + and - buttons
        buttonLayout = QVBoxLayout()
        addButton = QPushButton("+")
        removeButton = QPushButton("-")
        buttonLayout.addWidget(addButton)
        buttonLayout.addWidget(removeButton)
        vrmsLayout.addWidget(buttonLayout)

        addButton.connect(vrmForm.insertRow)



class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        super(MainWindow, self).__init__(parent)
        self.MDI = QMdiArea()
        self.setCentralWidget(self.MDI)
        SubWindow1 = QMdiSubWindow()
        SubWindow1.setWidget(testWidget())
        self.MDI.addSubWindow(SubWindow1)
        SubWindow1.show()
        # you can add more widgest
        #SubWindow2 = QtWidgets.QMdiSubWindow()


"""
***
to run in console

import demandVRMsForm.demand_form as t
t.createConnection()
t.VRM_DemandForm(iface)

from demandVRMsForm.ui.VRM_Demand_dialog import VRM_DemandDialog

from TOMs.core.TOMsMessageLog import TOMsMessageLog
from demandVRMsForm.vrmWidget import vrmWidget
import functools

supplyLayer = QgsProject.instance().mapLayersByName('Supply')[0]
# get first feature
for feature in supplyLayer.getFeatures():
    currRestriction = feature
    break

restrictionDialog = iface.getFeatureForm(supplyLayer, currRestriction)
vrmsTab = restrictionDialog.findChild(QWidget, "VRMs")
vrmsLayout = vrmsTab.layout()

vrmForm = vrmWidget(vrmsTab)
currGeometryID = currRestriction.attribute("gid")
currGeometryID = 28

vrmForm.populateDemandWidget(surveyID, currGeometryID)
vrmsLayout.addWidget(vrmForm)

buttonLayout = QVBoxLayout()
addButton = QPushButton("+")
removeButton = QPushButton("-")
buttonLayout.addWidget(addButton)
buttonLayout.addWidget(removeButton)
vrmsLayout.addLayout(buttonLayout, 0, 1, 1, 1, alignment=QtCore.Qt.AlignHCenter)

addButton.clicked.connect(functools.partial(vrmForm.insertVrm, surveyID, currGeometryID))
removeButton.clicked.connect(vrmForm.deleteVrm)

restrictionDialog.show()
...
t = VRM_DemandForm(iface)



from qgis.PyQt.QtSql import (
    QSqlDatabase, QSqlQuery, QSqlQueryModel, QSqlRelation, QSqlRelationalTableModel, QSqlRelationalDelegate
)
from TOMs.core.TOMsMessageLog import TOMsMessageLog
import demandVRMsForm.demand_form as t
t.createConnection()
vrmView = QTableView()
vrmModel = QSqlRelationalTableModel()
vrmModel.setTable("VRMs")

vrmModel.setFilter("SurveyID = 1 AND SectionID = 28")
vrmModel.setSort(int(vrmModel.fieldIndex("PositionID")), Qt.AscendingOrder)
vrmModel.setRelation(int(vrmModel.fieldIndex("VehicleTypeID")), QSqlRelation('VehicleTypes', 'Code', 'Description'))
rel = vrmModel.relation(int(vrmModel.fieldIndex("VehicleTypeID")))
if not rel.isValid():
    print ('Relation not valid ...')
    TOMsMessageLog.logMessage("In populateDemandWidget: Relation not valid ... {} ".format(vrmModel.lastError().text()),
                              level=Qgis.Warning)

result = vrmModel.select()
if result == False:
    TOMsMessageLog.logMessage("In populateDemandWidget: No result from select: {} ".format(vrmModel.lastError().text()),
                              level=Qgis.Warning)
    #print ('Select: {}'.format(my_model.lastError().text()))

TOMsMessageLog.logMessage(
    "In populateDemandWidget: nr Rows: {} ".format(vrmModel.rowCount()),
    level=Qgis.Warning)

#show the view with model
vrmView.setModel(vrmModel)
vrmView.setColumnHidden(vrmModel.fieldIndex('fid'), True)
vrmView.setColumnHidden(vrmModel.fieldIndex('ID'), True)
vrmView.setColumnHidden(vrmModel.fieldIndex('SurveyID'), True)
vrmView.setColumnHidden(vrmModel.fieldIndex('SectionID'), True)
vrmView.setColumnHidden(vrmModel.fieldIndex('GeometryID'), True)
vrmView.setItemDelegate(QSqlRelationalDelegate(vrmModel))
#vrmView.resizeColumnsToContents()
vrmView.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn);


for i in range(record.count()):
    print ("item {}, type: {}; value:{}".format(i, record.field(i).typeID(), record.field(i).value()))

***
"""
