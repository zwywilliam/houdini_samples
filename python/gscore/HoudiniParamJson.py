#coding=utf-8

import json

import hou
node = hou.pwd() 
geo = node.geometry()


'''

Integer01_# 结尾是数字，有_
Integer#_#  如果后面结尾不是数字，没有_




{
"IntegerVal":{"t":"int","v":1},
"IntArray_1":{"int":1},
"RampVal":{"ramp":{{1,1,1},{0,0.5,1},{0,1,0}}},
"StructArray_Num":{"int":1},
"RampIn_StructArray_1":{"t":"ramp","v":{{1,1,1},{0,0.5,1},{0,1,0}}},
"RampIn_StructArray_2":{"t":"ramp","v":{{1,1,1},{0,0.5,1},{0,1,0}}},
"IntIn_ArrayIn_Array_1_1":{"int":1},
"Mesh":{"t":"path","v":"/Game/testasset"},
}

see http://127.0.0.1:48626/hom/hou/Ramp.html for ramp definition

'''

ramp_dict = [None, hou.rampBasis.Linear, hou.rampBasis.Constant, hou.rampBasis.CatmullRom, hou.rampBasis.MonotoneCubic, hou.rampBasis.Bezier, hou.rampBasis.BSpline, hou.rampBasis.Hermite]


class HoudiniParamJson(object):
    def __init__(self):
        pass

    def ramp_interpolate_arr(self, arr):
        global ramp_dict
        arr_num = len(arr)
        for i in range(arr_num):
            arr[i] = ramp_dict[arr[i]]


    def load_parameter_and_apply(self, path):
        f = open(path)
        jsontxt = f.read()
        f.close()
        items = json.loads(jsontxt)

        for (k,v) in items.items(): 
            #geo.addAttrib(hou.attribType.Global, k, v)
            itemtype = v["t"]
            if itemtype == "ramp_float":
                self.ramp_interpolate_arr(v["v"])
                param = hou.node("../").parm(k)
                rampobj = hou.Ramp(v["v"], v["x"], v["y"])
                if param != None:
                    param.set(rampobj)
            elif itemtype == "float_interval":
                param = hou.node("../").parm(k+"min")
                if param != None:
                    param.set(v["v"])
                param = hou.node("../").parm(k+"max")
                if param != None:
                    param.set(v["v1"])
            else:
                param = hou.node("../").parm(k)
                if param != None:
                    param.set(v["v"])

    def load_detail_and_apply(self, path):
        # this function is for debug purpose

        f = open(path)
        jsontxt = f.read()
        f.close()
        print jsontxt
        items = json.loads(jsontxt)

        for (k,v) in items.items(): 
            print k
            #geo.addAttrib(hou.attribType.Global, k, v)
            itemtype = v["t"]
            if itemtype == "ramp_float":
                pass
            elif itemtype == "float_interval":
                pass
            else:
                geo.addAttrib(hou.attribType.Global, k, v["v"])
                print k
                print v
