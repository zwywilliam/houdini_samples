#coding=utf-8

import json

import hou
node = hou.pwd() 
geo = node.geometry()

class HoudiniDebug(object):
    def __init__(self):
        pass

    @staticmethod
    def enable_log(path):
        hou.putenv("GS_LOG_PATH", path)

    @staticmethod
    def clear_log():    
        log_path = hou.getenv("GS_LOG_PATH")
        if log_path != None:
            f = open(log_path, 'w')
            if f != None:
                f.close()


    @staticmethod
    def log_d(str):
        log_path = hou.getenv("GS_LOG_PATH")
        if log_path != None:
            f = open(log_path, 'a')
            if f != None:
                f.write(str+'\n')
                f.close()

