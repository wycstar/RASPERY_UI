#!/usr/bin/env python
# -*-coding:utf-8-*-

import sys
from PyQt5.QtCore import QObject, pyqtSlot
from time import sleep
import random

class Tools(QObject):
    def __init__(self, root, context, port):
        QObject.__init__(self)
        self.root = root
        self.context = context
        self.port = port

    @pyqtSlot()
    def closeApplication(self):
        self.port.t.stop()
        sleep(1)
        self.port.serialHandle.isRun = False
        self.port.serialHandle.s.close()
        sys.exit()

    @pyqtSlot()
    def clearGraph(self):
        self.port.serialHandle._hyPower = []
        self.port.serialHandle._liPower = []
        self.port.serialHandle._allPower = []
        self.port.serialHandle._x = 0

def fakeData(power):
    r = random.uniform(-30, 30)
    return (800 + r) if power > (800 + r) else power * 0.8

