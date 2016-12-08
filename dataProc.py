#!/usr/bin/env python
# -*-coding:utf-8-*-

from PyQt5.QtCore import QTimer, QMetaObject, QVariant, Q_ARG, Q_RETURN_ARG, Qt, QObject, pyqtProperty
from tty import CustomSerial

class GraphRefresh():
    def __init__(self, com, baud, interval, root, context):
        self.root = root[0]
        self.context = context
        self.serialHandle = CustomSerial(com, baud, self.root, self.context)
        self.t = QTimer()
        self.t.setInterval(interval * 1000)
        self.t.timeout.connect(self.timerHandler)
        self.serialHandle.setDaemon(True)
        self.serialHandle.start()
        self.t.start()

    def timerHandler(self): 
        self.root.b(self.serialHandle.seriesData, self.serialHandle.pointData)
