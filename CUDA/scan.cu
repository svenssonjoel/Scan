

#include <stdio.h> 
#include <stdlib.h> 
#include <stdint.h> 


__global__ void silly_kernel(int n, int* in, int* out) {
  
  if (threadIdx.x == 0){ 
    int acc = 0; 
    
    for (int i = 0; i < n; ++i){ 
      acc += in[i]; 
      out[i] = acc; 
    }
  }
}







#define SIZE 10
int main(int argc, char **argv) {
  
  int *in = NULL; 
  int *out = NULL; 

  in = (int*)malloc(SIZE*sizeof(int)); 
  out = (int*)malloc(SIZE*sizeof(int)); 

  int *din = NULL; 
  int *dout = NULL;
  
  cudaMalloc((void**)&din,SIZE*sizeof(int)); 
  cudaMalloc((void**)&dout,SIZE*sizeof(int)); 

  // Generate some data 
  for (int i = 0; i < SIZE; i ++) { 
    in[i] = i+1;
  }
  
  
  cudaMemcpy(din,in,SIZE*sizeof(int),cudaMemcpyHostToDevice);

  silly_kernel<<<1,1,0>>>(SIZE,din,dout); 

  cudaMemcpy(out,dout, SIZE*sizeof(int),cudaMemcpyDeviceToHost); 

  cudaFree(din);
  cudaFree(dout);
  
  for (int i = 0; i < SIZE; ++i) {
    printf("%d ", out[i]);
  }
  printf("\n"); 

  
  

  return 0;
} 
