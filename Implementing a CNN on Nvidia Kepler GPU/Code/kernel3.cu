__device__ float L[10];

__global__ void kernel3(float*fc1_w, float* fc2_w){
int a=threadIdx.y*32+threadIdx.x;
  if(I[a]+fc1_b[a]>0){
    I[a]=I[a]+fc1_b[a];}
    else I[a]=0;
     //j=10 a=512
       for(int j=0;j<10;j++)
  atomicAdd(&L[j],I[a]*fc2_w[a*10+j]);
  
 }