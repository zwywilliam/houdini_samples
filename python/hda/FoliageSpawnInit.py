from gscore.HoudiniParamJson import HoudiniParamJson

import os
import terraintoolutils
import hou


class FoliageSpawnInit(object):
    def __init__(self):
        pass

    def run(self):
        parmUseJsonInput = hou.node("../").parm("UseJsonInput")
        if parmUseJsonInput != None:
            valUseJsonInput = parmUseJsonInput.evalAsInt()
            if valUseJsonInput > 0:
                hjson = HoudiniParamJson()
                hippath = os.getenv('HIP', "unknown path")
                hjson.load_parameter_and_apply(hippath + "/tmp/foliage_spawn.json")
                #hjson.load_detail_and_apply(hippath + "/tmp/foliage_spawn.json")

        
        node = hou.pwd()
        geo = node.geometry()
        range = terraintoolutils.computeInputRange(node, 'height')

        if geo.findPrimAttrib("minHeight") == None:
            geo.addAttrib(hou.attribType.Global, "minHeight", range[0])
            geo.addAttrib(hou.attribType.Global, "maxHeight", range[1])
        else:
            geo.setGlobalAttrib("minHeight", range[0])
            geo.setGlobalAttrib("maxHeight", range[1])