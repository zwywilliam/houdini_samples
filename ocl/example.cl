#include "include/heightfield.cl"

/*
opencl用法

kernel页签
1.opencl可以使用外部文件作为主代码：$HIP/../ocl/example.cl
2.include文件时需要在kernel options加上-I$HIP/../ocl/以便引用路径
3.如果存在读写竞争的问题，则应该将写的内容写到临时的volume，然后使用write back kernel将临时volume复制到最终volume
4.如果需要预定义宏，可以在kerneal options加上-D宏名字。

options页签
1.对地形处理一般要选择first writeable volume，然后kernel线程设置相关的信息会以这个volume的size为准

bindings页签
1.kernel的线程设置与first writeable volume的xyz维度一致
2.任何一个volume的大小会通过  volume名_stride_x/y/z/stride_offset传递
  1.如果勾选了force alignment，则不会提供单独的大小参数，而统一使用  stride_x/y/z/stride_offset，但前提是volume大小与输出volume一致才可以，否则报错
  2.如果没有勾选force alignment，则可以勾选额外的voxel参数，比如例子中的voxelsize_x/y/z，参数的名字和顺序都是有约定规则的，参考例子做即可
3.注意正确勾选readable和writable
4.如果勾选optional，则可以通过#ifdef HAS_变量名  来检查某个变量是否有效。


参考
1.heightfield的大部分节点都是用opencl实现的，可以直接参考
2.另外可以参考3rd/AmbientOcclusion，也有比较复杂的用法，包括如何获取特定点周围的数据
3.如何同时处理heightfield和点集
   参考3rd/h16_5_ocl_examples/attribfromvolume.hip，大体方案就是首先需要将点集和地形merge，然后在opencl内读取点集的P，转换为地形的idx并获取相关值
   注意一次只能写入点集或者地形，无法两边同时写入
   另外可以参考https://www.cnblogs.com/peng-vfx/p/8989290.html


*/

kernel void kernelName(
    int height_stride_x,
    int height_stride_y,
    int height_stride_z,
    int height_stride_stride_offset,
    float height_voxelsize_x,
    float height_voxelsize_y,
    float height_voxelsize_z,
    global float * height,
    int mask_stride_x,
    int mask_stride_y,
    int mask_stride_z,
    int mask_stride_stride_offset,
    global float * mask,
    int param1
)
{
    //获取线程id
    int gidx = get_global_id(0);
    int gidy = get_global_id(1);
    int gidz = get_global_id(2);

    //地形的up向量
    float3 up = {0, 0, 1};
    //int idx = height_stride_stride_offset + height_stride_x * gidx + height_stride_y * gidy + height_stride_z * gidz;
    //由于地形的gidz总是0，所以可以忽略
    //对地形来说mask的大小和height一致，所以无需单独计算idx
    int idx = height_stride_stride_offset + height_stride_x * gidx + height_stride_y * gidy;

    float3 P = {gidx, gidy, height[idx]};
    // 随便调用一个函数，用height计算一些数据（比如算normal）
    float3 N = buildVoxelNormal(
        gidx, gidy, height, height_stride_x, height_stride_y,
        height_stride_stride_offset, height_voxelsize_x);
    
    // 回写到mask
    mask[idx] = N.x;
}



