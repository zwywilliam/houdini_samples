
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

#endif
