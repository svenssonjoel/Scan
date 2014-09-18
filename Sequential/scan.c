

#include <stdio.h> 


int i_scan_plus(int n, int *in, int *out){
  
  int acc=0; 

  for (int i = 0; i < n ; ++i) { 
    acc += in[i]; 
    out[i] = acc;
  }

  return 0; 
}


int e_scan_plus(int n, int *in, int *out){ 
  
  int acc=0; 
  for (int i = 0; i < n; ++i) { 
    out[i] = acc; 
    acc += in[i]; 
  }


}  

int printResult(int n, int *data){ 

  for (int i = 0; i < n; ++i){ 
    printf("%d ", data[i]); 
    
  }
  printf("\n");


  return 0;
}


int main(int argc, char **argv) { 

  int in[] = {1,2,3,4,5,6,7,8,9,10}; 
  int out[10];
  
  int eout[10];
   
  i_scan_plus(10,in,out); 
  e_scan_plus(10,in,eout); 

  printResult(10,out); 
  printResult(10,eout);

  return 0;
} 
