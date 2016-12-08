#!/usr/bin/env python
#-*-coding:utf-8-*-

import sys
import os
from PyQt5.QtCore import QUrl, Qt, QTimer, QMetaObject, QObject
from PyQt5.QtGui import QGuiApplication
from PyQt5.QtQml import QQmlApplicationEngine
from dataProc import GraphRefresh
from tools import Tools

if __name__ == '__main__':
    cwd = sys.path[0]
    myApp = QGuiApplication(sys.argv)
    appLabel = QQmlApplicationEngine()
    appLabel.addImportPath(cwd)
    appLabel.addImportPath(cwd + '/qml')
    appLabel.load(cwd + '/splash.qml')
    root = appLabel.rootObjects()
    context = appLabel.rootContext()
    g = GraphRefresh("/dev/ttyUSB0", 115200, 1, root, context)
    tools = Tools(root, context, g)
    context.setContextProperty('pyRoot', tools)
    myApp.exec_()
    sys.exit()
