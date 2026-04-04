# -*- coding: utf-8 -*-
"""
/***************************************************************************
 loadOcc
                                 A QGIS plugin
 Loads data from occupancy survey
                             -------------------
        begin                : 2018-09-14
        copyright            : (C) 2018 by MHTC
        email                : th@mhtc.co.uk
        git sha              : $Format:%H$
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
 This script initializes the plugin, making it known to QGIS.
"""


# noinspection PyPep8Naming
def classFactory(iface):  # pylint: disable=invalid-name
    """Load loadOcc class from file loadOcc.

    :param iface: A QGIS interface instance.
    :type iface: QgsInterface
    """
    #
    from .loadDemand import loadDemand
    return loadDemand(iface)
