// fake sdf implementation
//
// simply sample in eight direction and found the closest intersection point
//
// reminder : P = {gidx, gidy, height[idx]};  Volume space

/*

*/

#include "include/heightfield.cl"


#include "interpolate.h" 
float lerpConstant( constant float * in, int size, float pos);

kernel void kernelName( 
                 int _length, 
                 global float *  
)
{
    // No writeable attribute provided

}


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
                 global float * vegetation_age,
                 float sample_distance,
                 int sample_step
)
{
    int gidx = get_global_id(0);
    int gidy = get_global_id(1);

    float sample_step_distance = sample_distance / sample_step;

    float dist = heightFieldFakeSDFWithMask(
        gidx,
        gidy,
        mask,
        stride_y,
        stride_offset,
        voxelsize_y,
        sample_step,
        sample_step_distance,
        0.5f// pivot
    );

    float age_value = clamp(dist, 0.0f, sample_distance);
    age_value = age_value / sample_distance;



    int idx = heightFieldGid2Index(gidx, gidy, stride_y, stride_offset);

    vegetation_age[idx] = age_value;
    
    // // Post-processing
    // ao_value = pow(ao_value, power);
    // ao_value = clamp(ao_value, 0.0f, 1.0f);
    // ao_value = 1 - ao_value;
    
    // ao[idx] = ao_value;
}
