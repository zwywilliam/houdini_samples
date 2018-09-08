// fake sdf implementation
//
// simply sample in eight direction and found the closest intersection point
//
// reminder : P = {gidx, gidy, height[idx]};  Volume space

/*

*/

#include "include/heightfield.cl"

/*
heightFieldFakeSDFWithMask(
    int gidx,
    int gidy,
    global float * mask,
    int stride_y,
    int stride_offset,
    float voxelsize,
    float sample_step_count,
    float sample_step_distance,
    float pivot_value
*/

kernel void kernelName( 
                 int stride_x,
                 int stride_y,
                 int stride_z,
                 int stride_offset,
                 float voxelsize_x, 
                 float voxelsize_y, 
                 float voxelsize_z, 
                 global float * mask,
                 global float * vegetation_viability,
                 float minHeight,
                 float maxHeight
)
{
    int gidx = get_global_id(0);
    int gidy = get_global_id(1);

    float sample_step_distance = sample_distance / sample_step;


    int idx = heightFieldGid2Index(gidx, gidy, stride_y, stride_offset);

    float heightmask = 0.0f;//fit(mask, 0.0f, 1.0f);
    float ramp = 0.0f;//chramp(ramp, heightmask);

    vegetation_viability[idx] = ramp;
}


//barrier(CLK_LOCAL_MEM_FENCE | CLK_GLOBAL_MEM_FENCE);