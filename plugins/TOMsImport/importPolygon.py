#-----------------------------------------------------------
# Licensed under the terms of GNU GPL 2
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#---------------------------------------------------------------------
# Tim Hancock 2019

from qgis.PyQt.QtCore import (
    QObject,
    QDate,
    pyqtSignal
)

from qgis.PyQt.QtWidgets import (
    QMessageBox,
    QAction
)

from qgis.core import (
    QgsMessageLog, QgsFeature, QgsGeometry,
    QgsFeatureRequest,
    QgsRectangle, QgsPointXY, QgsWkbTypes
)

from abc import ABCMeta, abstractstaticmethod
import math

from .snapTraceUtilsMixin import snapTraceUtilsMixin

class importPolygon(QObject, snapTraceUtilsMixin):
    def __init__(self, currFeature):
        super().__init__()

        QgsMessageLog.logMessage("In importPolygon: " + str(currFeature.id()), tag="TOMs panel")

        self.currFeature = currFeature
        self.currGeometry = currFeature.geometry()

    def getElementGeometry(self):
        pass


    def getListPointsInPolygonWithinTolerance(self, snapLayer, tolerance=None):
        """
        generate list of points that are within tolerance of the nearest line from SnapLayer
        """
        if not tolerance:
            tolerance = 0.5

        ptsList = []

        if self.currGeometry.isMultipart():
            if len(self.currGeometry.asMultiPolygon()) > 1:
                reply = QMessageBox.information(None, "Issue",
                                                "Feature is multipart ... " + self.currFeature.id(), QMessageBox.Ok)

        QgsMessageLog.logMessage("In getListPointsInPolygonWithinTolerance: " + str(self.currFeature.id()), tag="TOMs panel")

        currVertexNr = 0
        for part in self.currGeometry.parts():
            for v in part.vertices():

                if self.findNearestPointL(QgsPointXY(v), snapLayer, tolerance) is not None:
                    QgsMessageLog.logMessage("In getListPointsInPolygonWithinTolerance: vertex: " + str(currVertexNr) + ":" + str(v.x()) + ";" + str(v.y()), tag="TOMs panel")
                    ptsList.append((currVertexNr, QgsPointXY(v)))

                currVertexNr = currVertexNr + 1

        """ Now get list into order. Find start and make sure it is complete
            Making assumption that there is a single part making up the line """

        nrVertices = currVertexNr

        QgsMessageLog.logMessage("In getListPointsInPolygonWithinTolerance: " + str(len(ptsList)) + "; NrVertices: " + str(nrVertices),
                                 tag="TOMs panel")

        newLineList = []
        if nrVertices > len(ptsList):
            """ Check to see whether or not the last entered """
            QgsMessageLog.logMessage("In getListPointsInPolygonWithinTolerance ... slicing ...", tag="TOMs panel")

            splitIndex = self.getIndexForSplit(ptsList, nrVertices)
            endList = len(ptsList)

        else:

            """ Need to check the angles at each point. The smallest is the start point. """

            QgsMessageLog.logMessage("In getListPointsInPolygonWithinTolerance ... checking angles ...", tag="TOMs panel")

            splitIndex = self.findStartPointForLine()
            endList = len(ptsList) - 1

            if splitIndex is None:
                return newLineList

        QgsMessageLog.logMessage("In getListPointsInPolygonWithinTolerance. SplitIndex: " + str(splitIndex) + " ; " + str(endList), tag="TOMs panel")

        for (index, pt) in ptsList[splitIndex:endList]:
            QgsMessageLog.logMessage(
                "In reString: " + str(index) + "; pt: " + pt.asWkt(),
                tag="TOMs panel")
            newLineList.append(pt)

        for (index, pt) in ptsList[:splitIndex]:
            QgsMessageLog.logMessage(
                "In reString: " + str(index) + "; pt: " + pt.asWkt(),
                tag="TOMs panel")
            newLineList.append(pt)

        return newLineList

    def getIndexForSplit(self, ptsList, lenOriginalList):

        currListLocation = 0

        if len(ptsList) > 0:

            if ptsList[-1][0] == lenOriginalList-1:

                """ Loop back to find start of missing """

                currVertexNr = 0

                for (vertexNr, vertex) in ptsList:
                    if vertexNr != currListLocation:
                        break
                    currListLocation = currListLocation + 1

        return currListLocation

    def findStartPointForLine(self):

        """ For a polygon for which every vertex is close to the kerb, find the smallest angle """

        currVertexNr = 0
        smallAngleList = []

        for part in self.currGeometry.parts():
            for v in part.vertices():

                (beforeVertexNr, afterVertexNr) = self.currGeometry.adjacentVertices(currVertexNr)
                angle = self.angleAtVertex(v, self.currGeometry.vertexAt(beforeVertexNr), self.currGeometry.vertexAt(afterVertexNr))

                #currBisectorAngle = self.currGeometry.angleAtVertex(currVertexNr)
                #if currBisectorAngle < math.pi/2:
                QgsMessageLog.logMessage("In findStartPointForLine. vertex: " + str(currVertexNr) + "; " + str(angle), tag="TOMs panel")
                if angle < 90.0:
                    smallAngleList.append(currVertexNr)
                    QgsMessageLog.logMessage("In findStartPointForLine. ADDING: " + str(currVertexNr), tag="TOMs panel")

                currVertexNr = currVertexNr + 1

        smallAngleList.sort(reverse=True)

        return smallAngleList[0]