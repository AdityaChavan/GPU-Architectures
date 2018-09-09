/******************************************************************************
 *cr
 *cr            (C) Copyright 2010 The Board of Trustees of the
 *cr                        University of Illinois
 *cr                         All Rights Reserved
 *cr
 ******************************************************************************/


//INSERT KERNEL CODE HERE
__constant__ float conv_b[8];
__constant__ float fc1_b[512];
__constant__ float fc2_b[10];
__constant__ float conv_ww[830];
__constant__ float padded_img[37*37];

__device__ float reshape[28*28*8];
//__device__ float L[10];
__device__ float I[512];


__global__ void kernel1(){

__shared__ float conv_www[100];
//__shared__ float pad[28*28];
if(threadIdx.x<10&&threadIdx.y<10)
conv_www[threadIdx.x*10 + threadIdx.y]=conv_ww[threadIdx.x*10 + threadIdx.y+blockIdx.y*104];
;
//pad[threadIdx.x*10 + threadIdx.y]=padded_img[(threadIdx.x+4)*10 + (threadIdx.y+4)];

__syncthreads();

float sum = 0.0f;
      for(int i = 0; i < 10; ++i) {
      for(int j = 0; j <10 ; ++j) {
           if( threadIdx.x + j >= 4 && threadIdx.x + j < 33 && threadIdx.y + j >= 4 && threadIdx.y + j < 33) {
      sum += conv_www[i*10+j]* padded_img[(threadIdx.x + i)*33+ threadIdx.y + j];
           } 
      }  
      }
      
      
      
   if(sum+conv_b[blockIdx.y]>=0){
   reshape[blockIdx.y+threadIdx.x*28*8+threadIdx.y*8]=sum+conv_b[blockIdx.y];
   }
     else reshape[blockIdx.y+threadIdx.x*28*8+threadIdx.y*8]=0;
  
    
}//last 