#!/usr/bin/env python
# -*-coding:utf-8-*-

import serial
from time import sleep
import json
import threading
import tools
from Crypto.Cipher import AES
from binascii import a2b_hex

class CustomSerial(threading.Thread):
    '''自定义串口类'''
    def __init__(self, com, baud, root, context):
        threading.Thread.__init__(self)
        self.s = serial.Serial(com, baud)
        self.root = root
        self.context = context
        self.pointData = {}
        self.seriesData = {}
        self._hyPower = []
        self._liPower = []
        self._allPower = []
        self.x = []
        self.isRun = True
        self._x = 0
        self.key = '1234567890abcdef'
        self._d  = AES.new(self.key, AES.MODE_ECB, b'0' * 16)

    def run(self):
        while(self.isRun):
            try:
                content=self.s.readline().decode('utf-8')
                jc = self._d.decrypt(a2b_hex(content[:320])).decode('utf-8')
                jc = jc[:jc.find('}') + 1]
                j = json.loads(jc)     
                # print(j)          
                power = j["LiVolt"] * j["TotalCurrent"]
                # print(power)
                # hyPower = tools.fakeData(power)
                hyPower = j['HyVolt'] * j['DCInCurrent'] * 1.5
                # print(hyPower)
                self.pointData = {"HyTemp":j["HyTemp"],
                                  #"HyPress":29.22,
                                  "HyPress":j["HyPress"],
                                  "LiVolt":j["LiVolt"],
                                  "HyVolt":j["HyVolt"],
                                  "LiPower":power - hyPower if power > hyPower else 0,
                                  "HyPower":hyPower}
                if self.root.property('isGraphPaint') and not self.root.property('isGraphPause'):
                    self._x += 1                  
                    self._hyPower.append(hyPower)
                    self._liPower.append(power - hyPower)
                    self._allPower.append(power)
                    self.seriesData = {"HyPower":self._hyPower[-300:],
                                       "LiPower":self._liPower[-300:],
                                       "AllPower":self._allPower[-300:],
                                       "x":list(range(self._x))[-300:]}
                sleep(0.1)

            except Exception as e:
                print(e)
                pass


if __name__ == "__main__":
    s = CustomSerial("COM7", 115200)
    s.start()
    while(True):
        print(s.seriesData)
        print(s.pointData)
        sleep(1)
        s.s.close()
