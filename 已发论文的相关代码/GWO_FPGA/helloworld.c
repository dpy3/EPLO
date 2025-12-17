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
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xdebug.h"
#include "xgwo.h"
#include <stdlib.h>
#include <math.h>
#include "xtime_l.h"
#include"xil_cache.h"

#define  Max_iter 100
#define sizepop 15
#define dim 2
#define SIZE 30
#define lb -512
#define ub 512

int main()
{
    init_platform();
//    Xil_DCacheDisable();

	XGwo Xgwo_inst;
	if(XGwo_Initialize(&Xgwo_inst, XPAR_GWO_0_DEVICE_ID)!= XST_SUCCESS)
		printf("error initialize axi_dma\n");

	float Positions[SIZE+5];
	float *Pos = (float*)malloc((SIZE+5)*sizeof(float));

for(int r=0;r<11;r++){

	XTime tStart,tEnd;
	u32 tUsed;
	XTime_GetTime(&tStart);

	float fitness;
	float Alpha_score =10000.0;
	float Beta_score = 10000.0;
	float Delta_score = 10000.0;

	//初始化种群
	for(int i = 0; i < sizepop; i++)
	{
		for (int j=0;j<dim;j++)
		{
			Positions[i*dim+j]=(float)rand()/RAND_MAX*(ub-lb)+lb; //lb到ub之间的随机数
		}

//		Positions[i*dim]=(float)rand()/RAND_MAX*20-15;
//		Positions[i*dim+1]=(float)rand()/RAND_MAX*6-3;
	}

	  //迭代循环，搜索最优解
		for(int iter=0;iter<Max_iter;iter++)
		{
		//计算适应度值
		 for(int i = 0; i < sizepop; i++)
			{
/*			//Sphere function测试函数 (10)
			   float sum = 0.0;
				for (int j=0;j<dim;j++)
				{
					sum = sum +Positions[i*dim+j]*Positions[i*dim+j];
				}
				fitness = sum;

				//Rastrigin function (10)
				  float sum = 0.0;
				  float pi=3.141592657;
				for (int j=0;j<dim;j++)
				{
				 sum = sum + (Positions[i*dim+j]*Positions[i*dim+j] -10*cos(2*pi*Positions[i*dim+j]));
				}
				fitness = 10*dim + sum;

				//sum squares function(10)
				  float sum = 0.0;
				for (int j=1;j<=dim;j++)
				{
				 float x = Positions[i*dim+j-1];
				 sum = sum + j*x*x;
				}
				fitness = sum;

				//Styblinski-tang function (10)
				  float sum = 0.0;
				for (int j=0;j<dim;j++)
				{
				 float x = Positions[i*dim+j];
				 sum = sum +x*x*x*x - 16*x*x + 5*x;
				}
				fitness = sum/2;

				//schwefel function(10)
				float sum = 0.0;
				for (int j=0;j<dim;j++)
				{
					float y = fabs(Positions[i*dim+j]);
					sum = sum +Positions[i*dim+j]*sin(sqrt(y));
				 }
				fitness = 4189.829-sum;


				//DropWave function (2)
				 float x = Positions[i*dim];
				 float y = Positions[i*dim+1];
				 float xy=x*x+y*y;
				 fitness = -( 1+cos (12*sqrt(xy)))/(xy/2+2);

				//Shubert function (2)
				  float sum1 = 0,sum2 = 0;
				  float new1 = 0,new2 = 0;
				  float x = Positions[i*dim];
				  float y = Positions[i*dim+1];
				for (int j=1;j<=5;j++)
				{
				 new1 = j * cos((j+1)*x+j);
				 new2 = j * cos((j+1)*y+j);
				 sum1 = sum1 + new1;
				 sum2 = sum2 + new2;
				}
				fitness = sum1 * sum2;

			    //Three-hump camel function (2)
				 float x = Positions[i*dim];
				 float y = Positions[i*dim+1];
				 fitness = 2*x*x - 1.05*x*x*x*x + x*x*x*x*x*x/6 + x*y + y*y;
*/
				//egg holder function(2)
				float x1 = Positions[i*dim];
				float x2 = Positions[i*dim+1];
				float new1=fabs(x2+x1/2.0+47);
				float new2=fabs(x1-(x2+47));
				fitness = -(x2+47)*sin(sqrt(new1))-x1*sin(sqrt(new2));
/*
			//six-hump camel function(2)
				float x1 = Positions[i*dim];
				float x2 = Positions[i*dim+1];
				fitness = (4-2.1*x1*x1+pow(x1,4)/3.0)*x1*x1+x1*x2+(-4+4*x2*x2)*x2*x2;

			//bukin n.6 function(2)
				float x1 = Positions[i*dim];
				float x2 = Positions[i*dim+1];
				float new1=fabs(x2-0.01*x1*x1);
				float new2=fabs(x1+10);
				fitness = 100*sqrt(new1)+0.01*new2;

			//levy n.13 function(2)
				float x1 = Positions[i*dim];
				float x2 = Positions[i*dim+1];
				float p1=sin(3*3.14*x1);
				float p2=sin(3*3.14*x2);
				float p3=sin(2*3.14*x2);
				fitness = p1*p1+(x1-1)*(x1-1)*(1+p2*p2)+(x2-1)*(x2-1)*(1+p3*p3);

			//goldstein-price function(2)
				float x1 = Positions[i*dim];
				float x2 = Positions[i*dim+1];
				float new1=(1+(x1+x2+1)*(x1+x2+1)*(19-14*x1+3*x1*x1-14*x2+6*x1*x2+3*x2*x2));
				float new2=(30+(2*x1-3*x2)*(2*x1-3*x2)*(18-32*x1+12*x1*x1+48*x2-36*x1*x2+27*x2*x2));
				fitness = new1*new2;
*/

			 //寻找三只狼
			   if(fitness < Alpha_score)
				{
					Alpha_score=fitness;
					Positions[SIZE] = i;
				}
				if(fitness > Alpha_score && fitness < Beta_score)
				{
					Beta_score=fitness;
					Positions[SIZE+1] = i;
				}
				if(fitness > Alpha_score && fitness > Beta_score && fitness < Delta_score)
				{
					Delta_score=fitness;
					Positions[SIZE+2] = i;
				}
			 }

		 	 Positions[SIZE+3]=iter;
		 	 Positions[SIZE+4]=5;

		 	  Xil_DCacheFlushRange((u32)Positions,(SIZE+5)*sizeof(float));

			 //执行灰狼算法主体结构
			  XGwo_Set_B(&Xgwo_inst,(u32)Positions);
			  XGwo_Set_Pos_r(&Xgwo_inst,(u32)Pos);
			  XGwo_Start(&Xgwo_inst);
			  while(XGwo_IsDone(&Xgwo_inst) == 0);

			 Xil_DCacheInvalidateRange((u32)Pos,(SIZE+5)*sizeof(float));

			  memcpy((float*)Positions,(const float*)Pos,(SIZE+5)*sizeof(float));

		}

		XTime_GetTime(&tEnd);
		tUsed=((tEnd-tStart)*1000)/(COUNTS_PER_SECOND);
//		printf("HW time is %ldms\n",tUsed);

//		printf("run = %d,bestfit = %e\n",r,Alpha_score);


//		printf("%e\n",Alpha_score);
		printf("%ld\n",tUsed);

		Xil_DCacheFlush();

}
    cleanup_platform();
    return 0;
}
