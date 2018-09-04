
#ifndef __HEIGHTFIELD_H__
#define __HEIGHTFIELD_H__

static float3
buildVoxelNormal(int gidx, 
                 int gidy,
                 global float* height,
                 int height_stride_x, 
                 int height_stride_y, 
                 int height_stride_offset, 
                 float height_voxelsize)
{
    private int west_idx = height_stride_offset + (height_stride_x * (gidx - 1)) + (height_stride_y * gidy);
    private int east_idx = height_stride_offset + (height_stride_x * (gidx + 1)) + (height_stride_y * gidy);
    private int south_idx = height_stride_offset + (height_stride_x * gidx) + (height_stride_y * (gidy - 1));
    private int north_idx = height_stride_offset + (height_stride_x * gidx) + (height_stride_y * (gidy + 1));
    
    private float3 west_pos = {gidx - height_voxelsize, gidy, height[west_idx]};
    private float3 east_pos = {gidx + height_voxelsize, gidy, height[east_idx]};
    private float3 south_pos = {gidx, gidy - height_voxelsize, height[south_idx]};
    private float3 north_pos = {gidx, gidy + height_voxelsize, height[north_idx]};
        
    private float3 ew = east_pos - west_pos;
    private float3 sn = north_pos - south_pos;
    
    private float3 n = normalize(cross(ew, sn));
    return n;
}


inline int heightFieldPos2Gid(float pos, float voxel_size)
{
    return round(pos / voxel_size);
}

inline int heightFieldPos2GidSafe(float pos, float voxel_size, int stride_y)
{
    return clamp((int)round(pos / voxel_size), 0, stride_y-1);
}

inline float2 heightFieldGid2Pos(int gidx, int gidy, float voxel_size)
{
    return (float2)(voxel_size * gidx, voxel_size * gidy);
}

inline int heightFieldGid2Index(int gidx, int gidy, int stride_y, int stride_offset)
{
    // stride_x = 1, gidz = 0, so ommit
    return gidx + gidy * stride_y + stride_offset;
}


/*
简单的伪sdf实现，向八方向发出射线，取最短的命中值
pivot用于定义边缘，低于pivot表示外围，高于pivot表示内部
起点的值低于pivot，则寻找高于pivot的位置，反之亦然
*/
static float heightFieldFakeSDFWithMask(
    int gidx,
    int gidy,
    global float * mask,
    int stride_y,
    int stride_offset,
    float voxelsize,
    float sample_step_count,
    float sample_step_distance,
    float pivot_value
)
{
    const int DIR_NUM = 8;
    const float DIR_ANGLE = 2.0f * 3.141592f / DIR_NUM;// 2pi = 360 degree

    float ret_dist = sample_step_distance * sample_step_count;
    float2 origin_pos = heightFieldGid2Pos(gidx, gidy, voxelsize);
    float2 cur_pos = origin_pos;

    int origin_idx = heightFieldGid2Index(gidx, gidy, stride_y, stride_offset);
    float origin_value = mask[origin_idx];
    float pivot_diff = pivot_value - origin_value;

    // 8 dir, detect pivot, be caution with heightfield's edge
    for(int dir_idx = 0; dir_idx < DIR_NUM; dir_idx++)
    {
        float angle = dir_idx * DIR_ANGLE;
        float2 move_dir = {cos(angle) * sample_step_distance, sin(angle) * sample_step_distance};
        cur_pos = origin_pos;
        for(int step_idx = 0; step_idx < sample_step_count; step_idx++)
        {
            int new_gidx = heightFieldPos2GidSafe(cur_pos.x, voxelsize, stride_y);
            int new_gidy = heightFieldPos2GidSafe(cur_pos.y, voxelsize, stride_y);

            int sample_idx = heightFieldGid2Index(new_gidx, new_gidy, stride_y, stride_offset);
            float sample_value = mask[sample_idx];

            float sample_diff = pivot_value - sample_value;
            if(sample_diff * pivot_diff < 0) // found edge
            {
                ret_dist = min(ret_dist, sample_diff);
                break;
            }

            cur_pos += move_dir;
        }
    }

    // todo: avoid if/else
    if(pivot_diff > 0)
    {
        return ret_dist;
    }
    else
    {
        return -ret_dist;
    }
}


#endif // __HEIGHTFIELD_H__
