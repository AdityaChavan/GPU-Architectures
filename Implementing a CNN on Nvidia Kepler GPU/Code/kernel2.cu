__global__ void kernel2(float*fc1_w ){

int h=threadIdx.x*28+threadIdx.y;
__shared__ float reshape2[28*28];
 reshape2[threadIdx.x*28+threadIdx.y]=reshape[blockIdx.y*28*28+h];
 __syncthreads();
atomicAdd(&I[blockIdx.x],reshape2[h]*fc1_w[(blockIdx.y*28*28+h)*512+blockIdx.x]);
}