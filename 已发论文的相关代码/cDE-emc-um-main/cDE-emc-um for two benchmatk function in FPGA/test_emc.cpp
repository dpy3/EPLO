#include <stdio.h>
#include "ap_axi_sdata.h"
#include <math.h>
#include <string.h>
#include <time.h>
void cde_emc_bench(float *A,float *B);

int main()
{
	time_t start, end;      //记录程序开始结束时间
	float time_sum;        //记录程序运行时间

	float A[50],B[50];

	for(int i=0;i<50;i++){
		A[i]=i+0.5;
	}
	A[3] = 666;
	A[4] = 10000;
	A[5] = 2;
	A[6] = -5.12;
	A[7] = 5.12;
	for(int i=0;i<10;i++){
		printf("%f ",A[i]);
	}
	printf("\n");
	start = clock();        //程序开始时间
	cde_emc_bench(&A[0],&B[0]);
	end = clock();  //程序结束时间
	time_sum = (float)(end - start )*1000000 / (CLOCKS_PER_SEC);    //换算成秒
	printf("\ntime:  %f us\n",time_sum);

	for(int i=0;i<50;i++)
		printf("%f\n",B[i]);

	return 0;
}
