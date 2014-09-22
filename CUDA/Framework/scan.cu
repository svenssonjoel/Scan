

#include <stdio.h> 
#include <stdlib.h> 
#include <stdint.h> 

// Experiment with 3 part scans. 


__global__ void silly_kernel(int n, int* in, int* out) {
  
  if (threadIdx.x == 0){ 
    int acc = 0; 
    
    for (int i = 0; i < n; ++i){ 
      acc += in[blockIdx.x * n + i]; 
      out[blockIdx.x * n + i] = acc; 
    }
  }
}


__global__ void mid_kernel(int n, int *in, int *out) { 
  
  if (threadIdx.x == 0){ 
    int acc = 0; 
    
    for (int i = 0; i < n; ++i){ 
      acc += in[(i+1)*32 - 1]; 
      out[i] = acc; 
    }
  }
}


__global__ void post_kernel(int n, int *imm, int *aux, int *out) { 
  
 
  if (threadIdx.x == 0){
    
    int val = aux[blockIdx.x-1]; 
    if (blockIdx.x == 0) val = 0; 
    
    for (int i = 0; i < n; ++i){ 
      
      out[blockIdx.x * n + i] = imm[blockIdx.x * n + i] + val; 
    }
  }
} 




#define ELT_PER_BLOCK 32
#define NUM_BLOCKS    32

#define SIZE (ELT_PER_BLOCK * NUM_BLOCKS)
int main(int argc, char **argv) {
 
  int *in = NULL; 
  int *out = NULL; 
  
  // debug 
  int *imm = NULL; 
  int *aux = NULL; 
  
  in = (int*)malloc(SIZE*sizeof(int)); 
  out = (int*)malloc(SIZE*sizeof(int)); 

  // debug 
  imm = (int*)malloc(SIZE*sizeof(int)); 
  aux = (int*)malloc(NUM_BLOCKS*sizeof(int)); 

  int *din = NULL; 
  
  int *imm1 = NULL; 
  int *aux1 = NULL; 

  int *dout = NULL;
  

  // Allocate all GPU Storage
  cudaMalloc((void**)&din,SIZE*sizeof(int)); 
  cudaMalloc((void**)&imm1,SIZE*sizeof(int)); 
  cudaMalloc((void**)&aux1,NUM_BLOCKS*sizeof(int));
  cudaMalloc((void**)&dout,SIZE*sizeof(int)); 

  // Generate some data 
  for (int i = 0; i < SIZE; i ++) { 
    in[i] = i+1;
  }
  
  
  cudaMemcpy(din,in,SIZE*sizeof(int),cudaMemcpyHostToDevice);

  // silly_kernel<<<1,1,0>>>(SIZE,din,dout); 

  silly_kernel<<<NUM_BLOCKS,ELT_PER_BLOCK,0>>>(ELT_PER_BLOCK,din,imm1);
  mid_kernel<<<1,NUM_BLOCKS,0>>>(ELT_PER_BLOCK,imm1,aux1); 
  post_kernel<<<NUM_BLOCKS,ELT_PER_BLOCK,0>>>(ELT_PER_BLOCK,imm1,aux1,dout); 
  
  cudaMemcpy(out,dout, SIZE*sizeof(int),cudaMemcpyDeviceToHost); 

  //debug 
  cudaMemcpy(imm,imm1, SIZE*sizeof(int),cudaMemcpyDeviceToHost); 
  cudaMemcpy(aux,aux1, NUM_BLOCKS*sizeof(int),cudaMemcpyDeviceToHost); 

  cudaFree(din);
  cudaFree(dout);
  cudaFree(aux1);
  cudaFree(imm1);
  
  for (int i = 0; i < SIZE; ++i) {
    printf("%d ", out[i]);
  }
  printf("\n---------------------------------------------------------------------------\n"); 


  for (int i = 0; i < NUM_BLOCKS; ++i) {
    printf("%d ", aux[i]);
  }
  printf("\n---------------------------------------------------------------------------\n"); 

  for (int i = 0; i < SIZE; ++i) {
    printf("%d ", imm[i]);
  }
  printf("\n---------------------------------------------------------------------------\n"); 

  
  

  return 0;
} 
