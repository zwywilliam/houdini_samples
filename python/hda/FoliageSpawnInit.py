from gscore.HoudiniParamJson import HoudiniParamJson

import os



class FoliageSpawnInit(object):
    def __init__(self):
        pass

    def run(self):
        hjson = HoudiniParamJson()
        hippath = os.getenv('HIP', "unknown path")
        #hjson.load_parameter_and_apply(hippath + "/tmp/foliage_spawn.json")
        hjson.load_detail_and_apply(hippath + "/tmp/foliage_spawn.json")
        