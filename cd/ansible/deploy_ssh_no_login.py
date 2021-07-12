# encoding=utf8

import xlrd
import subprocess

def read_xml_2list():
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
    sshpassExist = subprocess.call('yum -y install sshpass openssh-server openssh-clients', shell=True)
    if sshpassExist != 0:
        print("yum命令无法安装sshpass")
    else:
        if subprocess.call('cat /root/.ssh/id_rsa', shell=True) == 0:
            print("配置文件已经存在，请核对是否与git使用的相互冲突")
        else:
            return subprocess.call("ssh-keygen -f /root/.ssh/id_rsa -P ''", shell=True)

def transferKey2RemoteDevice():
    devices=read_xml_2list()
    for device in devices :
        command = "sshpass -p " + device["password"] + " ssh-copy-id " +  " -i ~/.ssh/id_rsa.pub " + device["username"] + "@" + device["ip"]
        subprocess.call(command, shell=True)

uploadRSA()
transferKey2RemoteDevice()
