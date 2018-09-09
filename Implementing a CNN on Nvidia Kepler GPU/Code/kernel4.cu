
__global__ void kernel4(int* result ){
int a=threadIdx.x;
   //if(a==1) for(int i=0;i<30;i++){printf("%d  %f\n",i,J[i]);}
     //I[a]=*J[a];
     
     //*/
     
 //    for(int j=0;j<512;j++)
  //L[a]=L[a]+I[j]*fc2_w[j*10+a];
  //__syncthreads();
  
    L[a]=L[a]+fc2_b[a];
      __syncthreads();
  int maxm=0; 
    int res=0;
      if(a==0){
    for(int k=0;k<10;k++){
    if(maxm<L[k]){maxm=L[k]; res=k;}
   // printf("%f\n",L[k]);
    }
    *result=res;
    }//find max
     
     
     
 }