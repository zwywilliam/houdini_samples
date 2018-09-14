import json

import hou
node = hou.pwd() 
geo = node.geometry()


'''

{
"IntegerVal":{"t":"int","v":1},
"IntArray_1":{"int":1},
"RampVal":{"ramp":{0,0,0, 1,1,1}},
"StructArray_Num":{"int":1},
"RampIn_StructArray_1":{"ramp":{0,0,0, 1,1,1}},
"RampIn_StructArray_2":{"ramp":{0,0,0, 1,1,1}},
"IntIn_ArrayIn_Array_1_1":{"int":1},
}



'''




class HoudiniParamJson(object):
    def __init__(self):
        pass

    def load_parameter_and_apply(self, path):
        f = open(path)
        jsontxt = f.read()
        f.close()
        items = json.loads(jsontxt)

        for (k,v) in items.items(): 
            #geo.addAttrib(hou.attribType.Global, k, v)
            itemtype = v["t"]
            if itemtype == "ramp":
                pass
            else:
                hou.node("../").parm(k).set(v["v"])