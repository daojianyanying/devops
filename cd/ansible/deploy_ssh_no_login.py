# encoding=utf8

import xlrd
import os
import subprocess

def read_xml_2list() :
    deviceXml = xlrd.open_workbook('D:\\tools-idea\\github\\devops\cd\\ansible\\deviceInfo.xls')
    sheetDevice = deviceXml.sheet_by_name("Sheet1")
    rows = sheetDevice.nrows
    deviceInfoList = []
    for row in range(1, rows):
        col_values = sheetDevice.row_values(row)
        device = {"ip": col_values[0], "username": col_values[1], "password": col_values[2]}
        deviceInfoList.append(device)
    return deviceInfoList

def uploadRSA():
    os.system("")
    