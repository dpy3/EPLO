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
#include <string.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xdebug.h"
#include "xpso.h"
#include <stdlib.h>
#include <math.h>
#include "xtime_l.h"
#include"xil_cache.h"

#define sizepop 30
#define dim 2
#define maxgen 200
#define pi 3.141592657

int main()
{
    init_platform();
//    Xil_DCacheDisable();

    float popmax = 512;// 个体最大取值
	float popmin = -512; // 个体最小取值
	float Vmax = 51.2; // 速度最大值
	float Vmin = -51.2; //速度最小值

	XPso Xpso_inst;
	if(XPso_Initialize(&Xpso_inst, XPAR_PSO_0_DEVICE_ID)!= XST_SUCCESS)
		printf("error initialize axi_dma\n");

	float fit_fp_fg[sizepop*2+dim+3]; // 定义种群的适应度数组 + 个体极值适应度的值 + 群体极值的位置 + 群体极值适应度值
	float pb_pop_v[sizepop*dim*3];  // 个体极值的位置 + 定义种群数组 + 定义种群速度数组
	float *A1 = (float*)malloc((sizepop*2+dim+3)*sizeof(float));
	float *C1 = (float*)malloc((sizepop*dim*3)*sizeof(float));

//循环跑11次,cache刷新时第一次的值有偏差，取2~11次的值
for(int r=0;r<11;r++){

	XTime tStart,tEnd;
	u32 tUsed;
	XTime_GetTime(&tStart);

	fit_fp_fg[sizepop*2+dim]=10000;

	// 种群初始化
	for(int i=0;i<sizepop;i++)
	{
		for(int j=0;j<dim;j++)
		{
			int temp=i*dim+j;
			//随机生成种群
			pb_pop_v[temp+sizepop*dim] = (float)rand()/RAND_MAX*(popmax-popmin)+popmin;
			pb_pop_v[temp+sizepop*dim*2] =(float)rand()/RAND_MAX*(Vmax-Vmin)+Vmin;
			// 个体极值位置
			pb_pop_v[temp] = pb_pop_v[temp+sizepop*dim];
		}

	}

	//迭代寻优
   for(int m=0;m<maxgen;m++)
	{
	   //计算种群的适应度值
		 //egg holder function(2)
		 for(int i=0;i<sizepop;i++)
		 {
			 float x1 = pb_pop_v[i*dim+sizepop*dim];
			 float x2 = pb_pop_v[i*dim+1+sizepop*dim];
			 float new1=fabs(x2+x1/2.0+47);
			 float new2=fabs(x1-(x2+47));
			 fit_fp_fg[i] = -(x2+47)*sin(sqrt(new1))-x1*sin(sqrt(new2));
		 }

	   //赋初值
	   if(m==0)
	   {
		   for(int i=0;i<sizepop;i++)
			{
			   // 个体极值适应度值
				fit_fp_fg[i+sizepop] = fit_fp_fg[i];
				//种群极值适应度值
				if(fit_fp_fg[i]<fit_fp_fg[sizepop*2+dim])
				{
					fit_fp_fg[sizepop*2+dim]=fit_fp_fg[i];
					// 群体极值位置
					for(int k=0;k<dim;k++)
					{
						fit_fp_fg[sizepop*2+k] = pb_pop_v[i*dim+k+sizepop*dim];
					 }
				}
			}
	   }

	   fit_fp_fg[sizepop*2+dim+1]=m;
	   fit_fp_fg[sizepop*2+dim+2]=5;

	   Xil_DCacheFlushRange((u32)fit_fp_fg, (sizepop*2+dim+3)*sizeof(float));
	   Xil_DCacheFlushRange((u32)pb_pop_v, (sizepop*dim*3)*sizeof(float));

	   //执行主体部分
	   XPso_Set_A(&Xpso_inst,(u32)fit_fp_fg);
	   XPso_Set_C(&Xpso_inst,(u32)pb_pop_v);
	   XPso_Set_A1(&Xpso_inst,(u32)A1);
	   XPso_Set_C1(&Xpso_inst,(u32)C1);
	   XPso_Start(&Xpso_inst);
	   while(XPso_IsDone(&Xpso_inst) == 0);

	   Xil_DCacheInvalidateRange((u32)A1, (sizepop*2+dim+3)*sizeof(float));
	   Xil_DCacheInvalidateRange((u32)C1, (sizepop*dim*3)*sizeof(float));

	   memcpy((float*)fit_fp_fg,(const float*)A1,(sizepop*2+dim+3)*sizeof(float));
	   memcpy((float*)pb_pop_v,(const float*)C1,(sizepop*dim*3)*sizeof(float));

	}

	XTime_GetTime(&tEnd);
	tUsed=((tEnd-tStart)*1000)/(COUNTS_PER_SECOND);
	printf("HW time is %ldms\n",tUsed);

	printf("run = %d, bestfit = %e\n",r,fit_fp_fg[sizepop*2+dim]);

	Xil_DCacheFlush();

}
    cleanup_platform();
    return 0;
}


