#include "mex.h"


void mexFunction(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[])
{

	int ergc = 3;
	char **ergv;
	int	buflen0, buflen1, status;
	char *buf0, *buf1;
	void maine(int, char**);
	ergv = mxCalloc(3,sizeof(char*));
/*	ergv[1] = mxCalloc(512,sizeof(char));
	ergv[2] = mxCalloc(512,sizeof(char));
*/	
	buflen0 = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
	buflen1 = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
	printf("%d\n",buflen0); 
    /* Allocate memory for input and output strings. */
    ergv[1]=mxCalloc(buflen0, sizeof(char));
	ergv[2]=mxCalloc(buflen1, sizeof(char));

    /* Copy the string data from prhs[0] into a C string 
     * input_ buf.
     * If the string array contains several rows, they are copied,
     * one column at a time, into one long string array.
     */
    status = mxGetString(prhs[0], ergv[1], buflen0);	
    status = mxGetString(prhs[1], ergv[2], buflen1);	
/*  	strcpy(buf0,argv[1]);
  	strcpy(buf1,argv[2]);
 	printf("%s\n", buf0);
	printf("%s\n", buf1); */
 	printf("%s\n", ergv[1]);
	printf("%s\n", ergv[2]); 
	
	maine(ergc,ergv);

}