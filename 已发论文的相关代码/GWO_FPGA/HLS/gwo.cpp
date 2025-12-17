#include <iostream>
#include <cmath>
#include<cstring>
#include <stdlib.h>
#include <ap_int.h>
#include<hls_stream.h>
using namespace std;

#define  Max_iter 100
#define sizepop 15
#define dim 2
#define SIZE 30
#define rand_max 4294967295

//随机数
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

void gwo(volatile float *B, volatile float *Pos)
{
	float Positions[SIZE+5];
	memcpy(Positions,(const float*)B,(SIZE+5)*sizeof(float));

	float ub,lb;
	float ub1,lb1;
	if((int)Positions[SIZE+4]==1)
	{
		ub=100;
		lb=-100;
		ub1=100;
		lb1=-100;
	}
	else if((int)Positions[SIZE+4]==2)
	{
		ub=5.12;
		lb=-5.12;
		ub1=5.12;
		lb1=-5.12;
	}
	else if((int)Positions[SIZE+4]==3)
	{
		ub=5;
		lb=-15;
		ub1=3;
		lb1=-3;
	}
	else if((int)Positions[SIZE+4]==4)
	{
		ub=10;
		lb=-10;
		ub1=10;
		lb1=-10;
	}
	else if((int)Positions[SIZE+4]==5)
	{
		ub=512;
		lb=-512;
		ub1=512;
		lb1=-512;
	}

	//初始化参数
	int Alpha_i = (int) Positions[SIZE];
	int Beta_i = (int) Positions[SIZE+1];
	int Delta_i = (int) Positions[SIZE+2];

    //三只狼的初始化
	float Alpha_pos[dim];
	float Beta_pos[dim];
	float Delta_pos[dim];

    //更新三只狼
	loop1:
	for(int z=0;z<dim;z++)
	{
		Alpha_pos[z]=Positions[Alpha_i*dim+z];
		Beta_pos[z]=Positions[Beta_i*dim+z];
		Delta_pos[z]=Positions[Delta_i*dim+z];
	}

	//a的值从2变化为0
	float a=2.0-(Positions[SIZE+3]*2)/Max_iter;
	pseudo_random(31,Positions[SIZE+3]+1);

	//根据Alpha狼、Beta狼、Delta狼的位置，更新种群
	loop2:
	for (int i=0;i<sizepop;i++)
	{loop2_1:
		for(int j=0;j<dim;j++)
		{
			float r1=pseudo_random(31,0);
			float A1=2*a*r1-a;
			float r2=pseudo_random(31,0);
			float C1=2*r2;
			float wolf=C1*Alpha_pos[j]-Positions[i*dim+j];
			if(wolf<0){
				wolf=-wolf;
			}
			float X1=Alpha_pos[j]-A1*wolf;

			r1=pseudo_random(31,0);
			float A2=2*a*r1-a;
			r2=pseudo_random(31,0);
			float C2=2*r2;
			 wolf=C2*Beta_pos[j]-Positions[i*dim+j];
			if(wolf<0){
				wolf=-wolf;
			}
			float X2=Beta_pos[j]-A2*wolf;

			r1=pseudo_random(31,0);
			float A3=2*a*r1-a;
			r2=pseudo_random(31,0);
			float C3=2*r2;
			 wolf=C3*Delta_pos[j]-Positions[i*dim+j];
			if(wolf<0){
				wolf=-wolf;
			}
			float X3=Delta_pos[j]-A3*wolf;

			//粒子更新
			Positions[i*dim+j]=(X1+X2+X3)/3; //Equation (3.7)
		}

		if(Positions[i*dim]>ub)
			Positions[i*dim]=ub;
		if(Positions[i*dim]<lb)
			Positions[i*dim]=lb;
		if(Positions[i*dim+1]>ub1)
			Positions[i*dim+1]=ub1;
		if(Positions[i*dim+1]<lb1)
			Positions[i*dim+1]=lb1;
	}

	memcpy((float*)Pos,(const float*)Positions,(SIZE+5)*sizeof(float));
}




