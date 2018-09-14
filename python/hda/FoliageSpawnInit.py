from gscore.HoudiniParamJson import HoudiniParamJson


class FoliageSpawnInit(object):
    def __init__(self):
        pass

    def run(self):
        hjson = HoudiniParamJson()
        hjson.load_parameter_and_apply("$HIP/tmp/foliage_spawn.json")