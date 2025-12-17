#include <iostream>
#include <cmath>
#include <cstdio>
#include <stdlib.h>
#include <ap_int.h>
#include<cstring>

using namespace std;

#define rand_max 4294967295
#define sizepop 30
#define dim 2


//随机数生成函数0-1
float pseudo_random(unsigned int seed, int load)
{
    static ap_uint<32> lfsr;
    if (load ==1)
        lfsr = seed;
    bool b_32 = lfsr.get_bit(32-32);
    bool b_22 = lfsr.get_bit(32-22);
    bool b_2 = lfsr.get_bit(32-2);
    bool b_1 = lfsr.get_bit(32-1);
    bool new_bit = b_32 ^ b_22 ^ b_2 ^ b_1;
    lfsr = lfsr >> 1;
    lfsr.set_bit(31, new_bit);
    float rand_num = (float)lfsr.to_uint()/rand_max;
    return rand_num;
}


// 迭代寻优
void pso(volatile float *A,volatile float *C,volatile float *A1,volatile float *C1)
{
#pragma HLS INTERFACE m_axi depth=180 port=C1 offset=slave
#pragma HLS INTERFACE m_axi depth=65 port=A1 offset=slave
#pragma HLS INTERFACE m_axi depth=180 port=C offset=slave
#pragma HLS INTERFACE m_axi depth=65 port=A offset=slave
#pragma HLS INTERFACE s_axilite port=return bundle=CTRL_BUS
	/*
	 * 说明：
	 *fit_fp_fg[j]==fitness[j];fit_fp_fg[sizepop+j]==fitnesspbest[j]
	 *fit_fp_fg[sizepop*2+k]==gbest[k];fit_fp_fg[sizepop*2+dim]==fitnessgbest
	 *
	 *
	*/

	float fit_fp_fg[sizepop*2+dim+3];
	memcpy(fit_fp_fg,(const float*)A,(sizepop*2+dim+3)*sizeof(float));
	float pb_pop_v[sizepop*dim*3];
	memcpy(pb_pop_v,(const float*)C,(sizepop*dim*3)*sizeof(float));

	float pbest[sizepop][dim],pop[sizepop][dim],V[sizepop][dim];
	//拆分
	loop1:
	for(int m=0;m<sizepop;m++){
#pragma HLS PIPELINE
		loop1_1:
		for(int n=0;n<dim;n++){
			int term=m*dim+n;
			pbest[m][n]=pb_pop_v[term];
			pop[m][n]=pb_pop_v[term+sizepop*dim];
			V[m][n]=pb_pop_v[term+sizepop*dim*2];
		}
	}

	int iter=(int)fit_fp_fg[sizepop*2+dim+1];
	int flag=(int)fit_fp_fg[sizepop*2+dim+2];

	float ub,lb;
	float ub1,lb1;
	if(flag==1)
	{
		ub=100;
		lb=-100;
		ub1=100;
		lb1=-100;
	}
	else if(flag==2)
	{
		ub=5.12;
		lb=-5.12;
		ub1=5.12;
		lb1=-5.12;
	}
	else if(flag==3)
	{
		ub=5;
		lb=-15;
		ub1=3;
		lb1=-3;
	}
	else if(flag==4)
	{
		ub=10;
		lb=-10;
		ub1=10;
		lb1=-10;
	}
	else if(flag==5)
	{
		ub=512;
		lb=-512;
		ub1=512;
		lb1=-512;
	}

	pseudo_random(31, iter+1);

	float c = 1.4962; //加速度因子一般是根据大量实验所得
	float w = 0.7;

	loop2:
	for(int i=0;i<sizepop;i++)
	{
		// 个体极值更新
	   if(fit_fp_fg[i] < fit_fp_fg[sizepop+i])
	   {
		 loop2_1:
		 for(int j=0;j<dim;j++)
		   {
#pragma HLS PIPELINE
			 pbest[i][j] = pop[i][j];
		   }
		 fit_fp_fg[sizepop+i] = fit_fp_fg[i];
	   }

	 // 群体极值更新
	  if(fit_fp_fg[i] < fit_fp_fg[sizepop*2+dim])
	   {
		 loop2_2:
		 for(int j=0;j<dim;j++)
		 {
#pragma HLS PIPELINE
			 fit_fp_fg[sizepop*2+j] = pop[i][j];
		 }
		 fit_fp_fg[sizepop*2+dim] = fit_fp_fg[i];
		}

		//速度更新及粒子更新
	    loop2_3:
		for(int j=0;j<dim;j++)
		{
#pragma HLS PIPELINE
			// 速度更新
			float rand1 = pseudo_random(31, 0); //0到1之间的随机数
			float rand2 = pseudo_random(31, 0);
			V[i][j] = w*V[i][j] + c*rand1*(pbest[i][j]-pop[i][j]) + c*rand2*(fit_fp_fg[sizepop*2+j]-pop[i][j]);

			// 粒子更新
			pop[i][j] = pop[i][j] + V[i][j];
		}

		//判断是否超出边界值
		if(pop[i][0]>ub)
			pop[i][0]=ub;
		if(pop[i][0]<lb)
			pop[i][0]=lb;
		if(pop[i][1]>ub1)
			pop[i][1]=ub1;
		if(pop[i][1]<lb1)
			pop[i][1]=lb1;
	}

	//合并
	loop3:
	for(int m=0;m<sizepop;m++){
#pragma HLS PIPELINE
		loop3_1:
		for(int n=0;n<dim;n++){
			int term=m*dim+n;
			pb_pop_v[term]=pbest[m][n];
			pb_pop_v[term+sizepop*dim]=pop[m][n];
			pb_pop_v[term+sizepop*dim*2]=V[m][n];
		}
	}

	memcpy((float*)A1,(const float*)fit_fp_fg,(sizepop*2+dim+3)*sizeof(float));
	memcpy((float*)C1,(const float*)pb_pop_v,(sizepop*dim*3)*sizeof(float));

	//cout<<"第"<<iter<<"代，最优值"<<fit_fp_fg[sizepop*2+dim]<<" \n ";
}



