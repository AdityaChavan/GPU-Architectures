/******************************************************************************
 *cr
 *cr            (C) Copyright 2010 The Board of Trustees of the
 *cr                        University of Illinois
 *cr                         All Rights Reserved
 *cr
 ******************************************************************************/

#include <stdio.h>
#include <iostream>
#include "support.h"
#include "kernel.cu"
#include "kernel2.cu"
#include "kernel3.cu"
#include "kernel4.cu"

int main(int argc, char* argv[])
{
	Timer timer;
	if (argc != 3) {
	    printf("\nInput files not specified");
	    exit(0);
	}
        char *inputImageFile = argv[1];
        char *labelFile = argv[2];

	// Initialize host variables ----------------------------------------------
	printf("\nSetting up the problem..."); fflush(stdout);
	startTime(&timer);
        
	// Allocate and initialize host variables ----------------------------------------------
	Matrix *conv_weight, conv_bias, fc1_weight, fc1_bias, fc2_weight, fc2_bias, test_image;
 
        input(inputImageFile, &conv_weight, &conv_bias, &fc1_weight, &fc1_bias, &fc2_weight, &fc2_bias, &test_image);

	dim3 dim_grid(1,8) , dim_block(28,28);
 	dim3 dim_grid2(512,8) , dim_block2(28,28);
  dim3 dim_grid3(1,1), dim_block3(16,32);
  dim3 dim_grid4(1,1), dim_block4(10,1);
 
	int result,*results;

	stopTime(&timer); 
	printf("%f s\n", elapsedTime(timer));

	// Allocate device variables ----------------------------------------------

	//INSERT DEVICE ALLOCATION CODE HERE
	
  printf("Allocating device variables..."); fflush(stdout);
	startTime(&timer);
  Matrix fc1_weight_d, fc2_weight_d, test_image_d;
  //Matrix A;
  Matrix conv_weight_1;
  Matrix padded_image=allocateMatrix(37,37);

  
cudaMalloc(&conv_weight_1.elements,(8*10*10+30)*sizeof(float));
cudaMalloc(&test_image_d.elements,28*28*sizeof(float));
//cudaMalloc(&(A).elements,8*28*28*sizeof(float));
cudaMalloc(&fc1_weight_d.elements,8*28*28*512*sizeof(float));
cudaMalloc(&fc2_weight_d.elements,10*512*sizeof(float));
cudaMalloc(&results,sizeof(int));


	cudaDeviceSynchronize();
	stopTime(&timer); 
	printf("%f s\n", elapsedTime(timer));
 //padding
 for(int i=0;i<37;i++)for(int j=0;j<37;j++) padded_image.elements[i*28+j]=0;
 for(int i=4;i<(32);i++){
   for(int j=4;j<(32);j++){
padded_image.elements[i*37+j]=test_image.elements[(i-4)*28+(j-4)];
}}
//*/ 
 
	// Copy host variables to device ------------------------------------------

	printf("Copying data from host to device..."); fflush(stdout);
	startTime(&timer);

	//INSERT HOST TO DEVICE COPY CODE HERE
cudaError_t cuda_ret;

cuda_ret=cudaMemcpyToSymbol(padded_img,padded_image.elements,37*37*sizeof(float));
if(cuda_ret!=cudaSuccess)FATAL("unable to allocate padded_img");


cuda_ret=cudaMemcpyToSymbol(conv_ww,conv_weight[0].elements,830*sizeof(float));
if(cuda_ret!=cudaSuccess)FATAL("unable to allocate conv_ww");

cuda_ret=cudaMemcpyToSymbol(conv_b,conv_bias.elements,8*sizeof(float));
if(cuda_ret!=cudaSuccess)FATAL("unable to allocate conv_bias");

cuda_ret=cudaMemcpy(fc1_weight_d.elements,fc1_weight.elements,8*28*28*512*sizeof(float),cudaMemcpyHostToDevice);
if(cuda_ret!=cudaSuccess)FATAL("unable to allocate fc1_weight_d");

cuda_ret=cudaMemcpy(fc2_weight_d.elements,fc2_weight.elements,10*512*sizeof(float),cudaMemcpyHostToDevice);
if(cuda_ret!=cudaSuccess)FATAL("unable to allocate fc2_weight_d");

cuda_ret=cudaMemcpy(results,&result,sizeof(int),cudaMemcpyHostToDevice);
if(cuda_ret!=cudaSuccess)FATAL("unable to allocate results");


cuda_ret=cudaMemcpyToSymbol(fc1_b,fc1_bias.elements,512*sizeof(float));
if(cuda_ret!=cudaSuccess)FATAL("unable to allocate fc1_bias");

cuda_ret=cudaMemcpyToSymbol(fc2_b,fc2_bias.elements,10*sizeof(float));
if(cuda_ret!=cudaSuccess)FATAL("unable to allocate fc2_bias");



	cudaDeviceSynchronize();
	stopTime(&timer); 
	printf("%f s\n", elapsedTime(timer));

	// Launch kernel ----------------------------------------------------------
	printf("Launching kernel..."); fflush(stdout);
	startTime(&timer);

	//INSERT KERNEL LAUNCH CODE HERE
//---------
//void convolution(float *conv_w, float *image,float*fc1_w, float* fc2_w){


kernel1<<<dim_grid,dim_block>>>();
kernel2<<<dim_grid2,dim_block2>>>(fc1_weight_d.elements);
kernel3<<<dim_grid3,dim_block3>>>(fc1_weight_d.elements,fc2_weight_d.elements);
kernel4<<<dim_grid3,dim_block3>>>(results);


//---------


	cuda_ret = cudaDeviceSynchronize();
	if(cuda_ret != cudaSuccess) FATAL("Unable to launch/execute kernel");

	cudaDeviceSynchronize();
	stopTime(&timer); 
	printf("%f s\n", elapsedTime(timer));

	// Copy device variables from host ----------------------------------------

	printf("Copying data from device to host..."); fflush(stdout);
	startTime(&timer);

	//INSERT DEVICE TO HOST COPY CODE HERE
cuda_ret=cudaMemcpy(&result,results,sizeof(int),cudaMemcpyDeviceToHost);
if(cuda_ret!=cudaSuccess)FATAL("unable to allocate result");

	cudaDeviceSynchronize();
	stopTime(&timer); 
	printf("%f s\n", elapsedTime(timer));
printf("\n\nRESULT is ......%d\n\n",result);

	// Verify correctness -----------------------------------------------------
        verify(result, labelFile);

	// Free host and device memory ------------------------------------------------------------

	return 0;
}


