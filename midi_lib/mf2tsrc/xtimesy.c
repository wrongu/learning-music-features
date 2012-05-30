#include "mex.h"


void xtimesy(double x[],double y[], double z[])
{
  z[0] = x[0]*y[0];
}

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *x,*y, *z;

  
  
  if(nrhs!=2) {
    mexErrMsgTxt("Two  inputs required.");
  } else if(nlhs>1) {
    mexErrMsgTxt("Too many  output arguments");
  }
    plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
  
  x = mxGetPr(prhs[0]);
  y = mxGetPr(prhs[1]);
  z = mxGetPr(plhs[0]);
  
 
  xtimesy(x,y,z);
}
