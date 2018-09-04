// Following numbers assume a 1024x1024 heightfield
//
// height_stride_offset is the total number of voxel. 1024x1024=1048576 in a 1k heightfield.
// height_stride_x = 1 ~ Start position of the voxel x ???
// height_stride_y = 1024 ~ Resolution of the heightfield
// height_stride_z = 1048576 ~ rezx * rezy ??
// gidx is index in x of voxel. There are 1024 voxels in x
// gidy is index in y of voxel. There are 1024 voxels in y
// gidz is index in z of voxel. It's always 0 as heightfields are 2D
// height_res_x = 1024
// height_res_y = 1024
// height_res_z = 1
// height_voxelsize_x, y, z = 1
//
// reminder : P = {gidx, gidy, height[idx]};  Volume space

#include "include/heightfield.cl"
#include "include/math3d.cl"

// /////////////////////////////////////////////////////////////////////////////////////////
// Function that will return a new vector from the a u and v float.
// The vector are generated like a hemisphere.
// /////////////////////////////////////////////////////////////////////////////////////////
float3 cosineSampleHemisphere(float u, float v) {
    float r = sqrt(u);
    float theta = 2.0f * 3.141592f * v;
    
    float x = r * cos(theta);
    float y = r * sin(theta);
    
    float max_value = max(0.0f, 1.0f - u);
    float3 vector = {x, y, sqrt(max_value)};
    
    vector = normalize(vector);
    return vector;
}

// Function that will return 1 if an intersection is detected when ray marching in a given direction.
// The check happens with the direction vector z pos and the height of the terrain under the vector.
float intersectInVolume(float3 voxel_position_vs,
                        float3 voxel_normal,
                        float3 sample_direction,
                        float sample_max_distance,
                        float distance_bias,
                        global float* height, 
                        int height_stride_y, 
                        int height_stride_offset,
                        float voxel_size)
{
    // Build the needed origins in the different spaces we use.
    // Example with a hypotetical 256x256 heightfield volume but with a 1x1 km in size.
    // origin_2d_vs = x:128 y:128             // The center voxel 2D position in volume space
    // origin_2d_ws = x:512 y:512             // The center voxel 2D position in world space
    // origin_3d_ws = x:512 y:512 z:height    // The center voxel 3D position in world space
    float  origin_height = voxel_position_vs.z;
    float2 origin_2d_vs  = {voxel_position_vs.x, voxel_position_vs.y};
    float2 origin_2d_ws  = {voxel_position_vs.x * voxel_size, voxel_position_vs.y * voxel_size};
    float3 origin_3d_ws  = {origin_2d_ws.x, origin_2d_ws.y, origin_height};
    
    // The move_direction is the direction (N) multiplied by the voxel_size.
    // Each iteration will move approx the length of the voxel size.
    // The move_length is used to increament the while loop so we can stop at the max_distance.
    float3 move_direction = sample_direction * voxel_size;
    float  move_length    = length(move_direction);
    
    // Define the start position (new_pos). We do this in World Space and add
    // the voxel_normal and the distance_bias to make sure we will not intersect
    // with the same voxel we are starting from.
    float3 new_pos = origin_3d_ws + (voxel_normal * distance_bias);
    
    // Init the ray travel distance to 0. This will be incremented when we ray march
    // in the while loop. When we have traveled more the the sample_max_distance we stop.
    float ray_travel_distance = 0.0f;
    
    // Start the while loop ray marching
    while (ray_travel_distance < sample_max_distance) {
        // Convert the position from World Space to Voxel Space
        // so we can sample the volume in the correct space.
        float new_pos_x_vs = new_pos.x / voxel_size;
        float new_pos_y_vs = new_pos.y / voxel_size;
    
        // Get the new position x and y volume index. We round them because we
        // don't want to sample a float position. Voxels are all int index.
        int new_gidx = round(new_pos_x_vs);
        int new_gidy = (round(new_pos_y_vs) * height_stride_y);
        
        // We remove 1 to both clamped values here make sure we dont go out of bound.
        new_gidx = clamp(new_gidx, 0, height_stride_y - 1);
        new_gidy = clamp(new_gidy, 0, (height_stride_y * height_stride_y) - 1);
        
        // Get the sample_idx to sample from and extract the height value from it (sample_height)
        int   sample_idx    = height_stride_offset + new_gidx + new_gidy;
        float sample_height = height[sample_idx];
        
        // Test if the ray height is lower than the sampled height. If yes, our ray is not
        // under the terrain so an intersection point is detected. Return 1 if so.
        // The return value is also considering the sample_max_distance value as weight.
        if (new_pos.z < sample_height) {
            return 1.0f - (ray_travel_distance / sample_max_distance);
        }
        
        // When no intersection is detected, we increment the new_pos in the move direction
        // essentialy ray marching one more step. We also increase the ray_travel_distance
        new_pos += move_direction;
        ray_travel_distance += move_length;
    }
    
    // When no intersection has been found, we return 0.
    return 0.0f;
}

kernel void kernelName( 
                 int height_stride_x, 
                 int height_stride_y, 
                 int height_stride_z, 
                 int height_stride_offset, 
                 int height_res_x, 
                 int height_res_y, 
                 int height_res_z, 
                 float height_voxelsize_x, 
                 float height_voxelsize_y, 
                 float height_voxelsize_z, 
                 global float * height,
                 int ao_stride_x, 
                 int ao_stride_y, 
                 int ao_stride_z, 
                 int ao_stride_offset, 
                 global float * ao,
                 float max_distance,
                 int samples,
                 float angle,
                 float protection_distance,
                 float power
)
{
    int gidx = get_global_id(0);
    int gidy = get_global_id(1);
    int gidz = get_global_id(2);

    // UP is in Volume Space
    float3 up = {0,0,1};
    int idx = height_stride_offset + height_stride_x * gidx + height_stride_y * gidy;
    
    float3 P = {gidx, gidy, height[idx]};
    float3 N = buildVoxelNormal(gidx,
                                gidy, 
                                height, 
                                height_stride_x, 
                                height_stride_y, 
                                height_stride_offset, 
                                height_voxelsize_x);

    float4 rotation = buildQuatFromTwoVectors(up, N);
    
    // This value will store the number of hit and the hit distance as well.
    // If a hit happened close to the max distance allowed, the hit sample
    // will have a low value.
    float hit_samples = 0;
    
    // Loop samples i
    for (int i = 0; i < samples; i++) {
        // Loop samples j
        for (int j = 0; j < samples; j++) {
            // The angle value limits the hemisphere rays to not shoot horizontaly.
            float n_i = (float)i / ((float)samples - angle);
            float n_j = (float)j / (float)samples;
            
            // Get a sample dir using the Hemisphere function
            float3 sample_dir = cosineSampleHemisphere(n_i, n_j);
            
            // Rotate the sample direction to put it in the N direction
            float3 rotated_sample_dir = rotateVectorByQuat(sample_dir, rotation);
            
            // Try to find an intersection
            hit_samples += intersectInVolume(P, 
                                             N, 
                                             rotated_sample_dir, 
                                             max_distance, 
                                             protection_distance,
                                             height, 
                                             height_stride_y, 
                                             height_stride_offset, 
                                             height_voxelsize_x);
        }
    }
    
    // Compute the AO value by dividing the hit sample and the number of samples.
    float ao_value = hit_samples / ((float)samples * (float)samples);
    
    // Post-processing
    ao_value = pow(ao_value, power);
    ao_value = clamp(ao_value, 0.0f, 1.0f);
    ao_value = 1 - ao_value;
    
    ao[idx] = ao_value;
}
