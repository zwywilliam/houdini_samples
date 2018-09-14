import json

import hou
node = hou.pwd() 
geo = node.geometry()


'''

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
            if itemtype == "ramp":
                self:ramp_interpolate_arr(v["v"][0])
                rampobj = hou.Ramp(v["v"][0], v["v"][1], v["v"][2])
                param.set(rampobj)
            else:
                param = hou.node("../").parm(k)
                if param != None:
                    param.set(v["v"])
