
#ifndef __MATH3D_H__
#define __MATH3D_H__

// /////////////////////////////////////////////////////////////////////////////////////////
// Rotate a vector by the supplied quaternion, returning a new vector.
// /////////////////////////////////////////////////////////////////////////////////////////
static float3
rotateVectorByQuat(float3 vector, 
                   float4 quat)
{
    // Extract the vector part of the quat
    private float3 quat_vector = {quat.x, quat.y, quat.z};
    
    // Extract the scalar part of the quat
    private float quat_scalar = quat.w;
    
    // Do the rotation
    private float3 t = 2.0f * cross(quat_vector, vector);
    private float3 rotated_vector = vector + (quat_scalar * t) + cross(quat_vector, t);
    
    rotated_vector = normalize(rotated_vector);
    return rotated_vector;
}

// /////////////////////////////////////////////////////////////////////////////////////////
// Build a quaternion rotation representing the rotation from v1 to v2.
// /////////////////////////////////////////////////////////////////////////////////////////
static float4
buildQuatFromTwoVectors(float3 v1, 
                        float3 v2)
{
    private float3 vector = cross(v1, v2);
    private float  v1_len = length(v1);
    private float  v2_len = length(v2);
    
    // Build the quat scalar value
    private float quat_w = sqrt(v1_len * v1_len * v2_len * v2_len) + dot(v1, v2);
    
    private float4 quat = {vector.x, vector.y, vector.z, quat_w};
    
    quat = normalize(quat);
    return quat;
}

#endif
