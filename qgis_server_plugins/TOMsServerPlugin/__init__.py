# -*- coding: utf-8 -*-
"""
from https://gis.stackexchange.com/questions/355319/register-custom-python-function-in-qgis-server-3-10

"""
from qgis.core import QgsMessageLog, Qgis, QgsExpression
from qgis.utils import qgsfunction

import TOMs.expressions as exp
from TOMs.core.TOMsMessageLog import TOMsMessageLog

#from TOMs.CadNodeTool.TOMsNodeTool import TOMsNodeTool, TOMsLabelTool

@qgsfunction(
    args='auto', group='Your group', usesGeometry=False, referencedColumns=[], helpText='Define the help string here')
def your_expression(params, feature, parent):
    # UPDATE the qgsfunction above
    # ADD HERE THE EXPRESSION CODE THAT YOU WROTE IN QGIS.
    return params.upper()

class ServerExpressionPlugin:
    def __init__(self):
        QgsMessageLog.logMessage('Loading expressions', 'ServerExpression', Qgis.Info)
        #QgsExpression.registerFunction(your_expression)

        for func in exp.TOMsExpressions().functions:
            QgsMessageLog.logMessage("Considering function {}".format(func.name()), 'ServerExpression', Qgis.Info)

            if QgsExpression.registerFunction(func):
                QgsMessageLog.logMessage("Registered expression function {}".format(func.name()), 'ServerExpression', Qgis.Info)


def serverClassFactory(serverIface):
    _ = serverIface
    return ServerExpressionPlugin()

"""
class TOMsServerMessageLog(TOMsMessageLog):

    def __init__(self):
        super().__init__()

    @staticmethod
    def logMessage(*args, **kwargs):
        # check to see if a logging level has been set
        def currentLoggingLevel():
            try:
                currLoggingLevel = QgsExpressionContextUtils.projectScope(QgsProject.instance()).variable('TOMs_Logging_Level')
            except Exception as e:

                QgsMessageLog.logMessage("Error in TOMsMessageLog. TOMs_logging_Level not found ... {}".format(e), 'ServerExpression', level=Qgis.Info)


            if not currLoggingLevel:
                currLoggingLevel = Qgis.Info
            return int(currLoggingLevel)

        debug_level = currentLoggingLevel()

        try:
            messageLevel = int(kwargs.get('level'))
        except Exception as e:
            QgsMessageLog.logMessage("Error in TOMsMessageLog level in message not found...{}".format(e), 'ServerExpression', level=Qgis.Info)
            messageLevel = Qgis.Info

        #QgsMessageLog.logMessage('{}: messageLevel: {}; debug_level: {}'.format(args[0], messageLevel, debug_level), tag="TOMs panel")

        if messageLevel >= debug_level:
            QgsMessageLog.logMessage(*args, 'ServerExpression', level=messageLevel)

    def setLogFile(self):

        try:
            logFilePath = os.environ.get('QGIS_LOGFILE_PATH')
        except Exception as e:
            QgsMessageLog.logMessage("Error in TOMsMessageLog. QGIS_LOGFILE_PATH not found ... ", 'ServerExpression', level=Qgis.Info)

        if logFilePath:
            QgsMessageLog.logMessage("LogFilePath: " + str(logFilePath), 'ServerExpression', level=Qgis.Info)

            logfile = 'qgis_' + datetime.date.today().strftime("%Y%m%d") + '.log'
            self.filename = os.path.join(logFilePath, logfile)
            QgsMessageLog.logMessage("Sorting out log file" + self.filename, 'ServerExpression', level=Qgis.Info)
            QgsApplication.messageLog().messageReceived.connect(self.write_log_message)

    def write_log_message(self, message, tag, level):
        QgsMessageLog.logMessage(message, tag, level=level)
        QgsMessageLog.logMessage(*args, **kwargs)
        with open(self.filename, 'a') as logfile:
            logfile.write(
                '{dateDetails}[{tag}]: {level} :: {message}\n'.format(dateDetails=time.strftime("%Y%m%d:%H%M%S"),
                                                                      tag=tag, level=level, message=message))

"""