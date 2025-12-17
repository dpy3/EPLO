/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include"xaxi_dma.h"
#include"xparameters.h"
#include "xtime_l.h"
#include <math.h>


int main()
{
	  init_platform();
	  Xil_DCacheDisable();
	  float *result = (float*)malloc(500*sizeof(float));
	  XAxi_dma XEa_inst;
	  if(XAxi_dma_Initialize(&XEa_inst,XPAR_AXI_DMA_0_DEVICE_ID)!=XST_SUCCESS)
				printf("error initialize QUATRE\n");
	  //start to compute
//	  XTime tEnd,tCur;
//	  u32 tUsed;
//	  XTime_GetTime(&tCur);
//
//	  int func=1;
//	  int iteration;
//	  int F = 6;
////	  unsigned int seed = 65534;
//	  printf("Function %d\n",func);
//	  unsigned int seed = (unsigned int) (1.0 * rand() / RAND_MAX * 50000 + 20000);
//	  XAxi_dma_Set_FUNC(&XEa_inst,func);
//	  XAxi_dma_Set_seed(&XEa_inst,seed);
//	  XAxi_dma_Set_Fin(&XEa_inst,F);
//	  XAxi_dma_Set_result(&XEa_inst,(u32)result);
//	  XAxi_dma_Start(&XEa_inst);
//	  while (XAxi_dma_IsDone(&XEa_inst) == 0);
//
//	  iteration = XAxi_dma_Get_Iteration(&XEa_inst);
//	  printf("Best Iteration = %d\n",iteration);
//	  printf("Best value = %e\n",result[499]);
//	  //printf("***********************************\n");
//
//	  XTime_GetTime(&tEnd);
//	  tUsed=((tEnd-tCur)*1000)/(COUNTS_PER_SECOND);
//	  printf("time costed is %d ms\n",(int)tUsed);
	  int func = 6;
	  int Iteration;
	  float gbestval;
	  float record[10];
	  int gen;
	  for(int i = 0; i < 10; i++){

		  unsigned int seed = (unsigned int) (1.0 * rand() / RAND_MAX * 50000 + 20000);
		  XAxi_dma_Set_FUNC(&XEa_inst,func);
		  XAxi_dma_Set_seed(&XEa_inst,seed);
		  XAxi_dma_Set_result(&XEa_inst,(u32)result);
		  XAxi_dma_Start(&XEa_inst);
  //		  printf("Best Iteration = %d\n",iteration);
		  while (XAxi_dma_IsDone(&XEa_inst) == 0);
		  Iteration = XAxi_dma_Get_Iteration(&XEa_inst);
  		  printf("Best Iteration in loop %d = %d\n",i, Iteration);
		  printf("Best value = %e\n",result[499]);
		  if(i==0)
		  {
			  gbestval = result[499];
			  gen = Iteration;
		  }else{
			  if(gbestval > result[499]){
				  gbestval = result[499];
				  gen = Iteration;
			  }else if(gbestval == result[499]){
				  if(gen > Iteration){
					  gen = Iteration;
				  }

			  }
		  }
		  record[i] = result[499];
	  }
	printf("Best Iteration = %d\n",gen);
	printf("Best value = %e\n",gbestval);
	double sum = 0.0;
	for(int i=0;i<10;i++){
		sum = sum+record[i];
	}
	double avg = sum/10;
	double sum1 = 0.0;
	for(int i=0;i<10;i++){
		sum1 = sum1 + pow(record[i] - avg, 2);
	}
	double stdD = sqrt(sum1/10);
	printf("Mean value = %e\n",avg);
	printf("Std value = %e\n",stdD);
    cleanup_platform();
    return 0;
}
