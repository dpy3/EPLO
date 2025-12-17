#include <ap_int.h>
#include <ap_cint.h>
#include <string.h>
#include <ap_fixed.h>
#include "ap_axi_sdata.h"
#define SIZE 50
#define N 10
#define PI 3.1415926535897932384626433832795029
int temp_lfsr;
float Rmax,Rmin,Rmaxmin;
int iternum;
int tfnum;
static int lfsr;

int LFSRfunc(int load,int seed,int minn, int Rmaxmin){
//#pragma HLS INLINE
    if(load ==1){
        lfsr = seed; //static
    }
    int bit;
    bit = ((lfsr >> 0) ^ (lfsr >> 1) ^ (lfsr >> 2) ^ (lfsr >> 3)) & 1;
    lfsr = (lfsr >> 1) | (bit << 15);
    return lfsr%(Rmaxmin)+minn;
}
float fitfunc_Rosenbrock(float pop[N]){
//#pragma HLS INLINE
    float re=0;
    for(int i=0;i<N-1;i++){
//#pragma HLS UNROLL
        re = re+100*(pop[i]*pop[i]-pop[i+1]*pop[i+1])*(pop[i]*pop[i]-pop[i+1]*pop[i+1])+(pop[i]-1)*(pop[i]-1);
    }
    return re;
}
float fitfunc_Rastrigin(float pop[N]){
//#pragma HLS INLINE
    float re = 0,temp=0;
    for(int i=0;i<N;i++){
//		#pragma HLS UNROLL
        temp = temp+ pop[i]*pop[i]-10*cos((double)(2*PI*pop[i]));
    }
    re = temp+10*N;
    return re;
}
float myerfinv03(float x){
//#pragma HLS INLINE
	float temp,re,x3,x6;
    x3 = x*x*x;
    x6 = x3*x3;
    temp = x+0.261799388*x3+0.143931731*x3*x*x+0.097663620*x6*x+0.073299079*x6*x3+0.058372501*x6*x3*x*x+0.048336063*x6*x6*x+0.041147395*x6*x6*x3;
    re = temp*(0.8862);
    return re;

}
float myerf01(float x){
//#pragma HLS INLINE
    float a1=0.278393,a2=0.230389,a3=0.000972,a4=0.078108;
    float t,rer;
    float txx,ttt;
    txx=x*x;
    t= 1+a1*x+a2*txx+a3*txx*x+a4*txx*txx;
    ttt = t*t;
    rer=1-1/(ttt*ttt);

    return rer;
}
//void test(float *A,float *B)
//{
//#pragma HLS INTERFACE s_axilite port=return bundle=CTRL //与start，done信号相关
//#pragma HLS INTERFACE m_axi depth=50 port=B offset=slave bundle=output
//#pragma HLS INTERFACE m_axi depth=50 port=A offset=slave bundle=input
//float ina[50];
//int intina;
//	for(int i=0;i<SIZE;i++)
//	{
//#pragma HLS PIPELINE
//		ina[i]=*(A+i);
//
//
//	}
//	for(int i=0;i<SIZE;i++){
//		intina = (int)ina[i];
//		if(i==2){
//			intina = intina+100;
//		}
//		*(B+i)=intina;
//	}
//}
void cde_emc_bench(float *A,float *B){
//#pragma HLS INTERFACE s_axilite port=return bundle=CTRL //与start，done信号相关
//#pragma HLS INTERFACE m_axi depth=50 port=B offset=slave bundle=output
//#pragma HLS INTERFACE m_axi depth=50 port=A offset=slave bundle=input

    float a[SIZE],re;
    float mu[N],sigma[N],mut,sigt;
	float best[N];
	float bestfit,xofffit;
	float los_l,win_l;
	float xoff[N];

	float F,Cr,tempF,templf;
	float rand_x1,rand_x2;
	float tempsqr; // 要有初始随机数种子
	int Rmaxmin,Rmaxmin2;
	float erf1,erf2,sigF,Rmed;



//	// read input
	for(int i=0;i<SIZE;i++)
	{
		a[i]=*(A+i);
	}
	temp_lfsr = (int)a[3];
	iternum = (int)a[4];
	tfnum = (int)a[5];
	Rmin = (float)a[6];
	Rmax = (float)a[7];

	//*******************************************
	// 初始化
	F= 0.7;//cinput.F;
	Cr = 0.9;//cinput.Cr;

	Rmed = 0.5*(Rmax+Rmin);
	Rmaxmin = Rmax-Rmin;
	Rmaxmin2 = 0.5*Rmaxmin;
//	temp_lfsr = seed;
	templf = LFSRfunc(1,temp_lfsr,Rmin,Rmaxmin);
	for(int i=0;i<N;i++){
		#pragma HLS UNROLL
		mu[i] = 0;
		sigma[i] = 10.0;
		best[i] = (float)LFSRfunc(0,temp_lfsr,Rmin,Rmaxmin);//lsfr_map(temp_lfsr,Rmin,Rmaxmin);//float(Rmin+rand()%(Rmaxmin+1));//chaos_map(rand_x,Rmin,Rmaxmin);
		xoff[i] = 0;
	}
	if(tfnum==1){
		bestfit = fitfunc_Rosenbrock(best);
	}
	else{
		bestfit = fitfunc_Rastrigin(best);
	}
	for(int i=1;i<iternum;i++){
		// 变异
		for(int j=0;j<N;j++){
			#pragma HLS UNROLL
			tempsqr = sigma[j]*1.414213562;
			erf1 = myerf01((mu[j]-1)/(tempsqr));
			erf2 = myerf01((mu[j]+1)/(tempsqr));
			rand_x1 = (float)LFSRfunc(0,temp_lfsr,0,9999)/10000.0;//rand()/double(RAND_MAX);// 随机数生成
			rand_x2 =(float)LFSRfunc(0,temp_lfsr,0,9999)/10000.0;//rand()/double(RAND_MAX);

			 if(rand_x2>((0.2)*(i/iternum)+0.7)){
				tempF = F+(i/iternum)*0.2;
				xoff[j] = (tempF)*(((best[j]-Rmed)/(Rmaxmin2))-mu[j])+mu[j]-tempsqr*(tempF-1)*myerfinv03(-rand_x1*erf1+(rand_x1-1)*erf2)+(rand_x2-0.5);
				xoff[j] =xoff[j]*Rmaxmin2+Rmed;
			}
			else{
				xoff[j] = best[j];//-Rmed)/(0.5*Rmaxmin);
			}
			if(xoff[j]>Rmax){xoff[j]=Rmax;}
			if(xoff[j]<Rmin){xoff[j]=Rmin;} //这种方法会不断地跳到边界，然后无法收敛
		}
		if(tfnum==1){
			xofffit = fitfunc_Rosenbrock(xoff);
		}
		else{
			xofffit = fitfunc_Rastrigin(xoff);
		}
		if(xofffit<bestfit){
			bestfit = xofffit;
		}
		for(int j=0;j<N;j++){
//		#pragma HLS UNROLL
			// 转换到PDF
			if(xofffit>bestfit){
				win_l = (best[j]-Rmed)/(Rmaxmin2);
				los_l = (xoff[j]-Rmed)/(Rmaxmin2);
			}else{
				win_l = (xoff[j]-Rmed)/(Rmaxmin2);
				los_l = (best[j]-Rmed)/(Rmaxmin2);
				best[j] = xoff[j];
			}

			mut = mu[j];
			mu[j] = mu[j]+(win_l-los_l)/10.0;
			sigt = sigma[j]*sigma[j]+mut*mut-mu[j]*mu[j]+(win_l*win_l-los_l*los_l)/10.0;
			sigma[j] =10.0;
			if(sigt>0){
				// 不能等于0 否则就陷入局部最优了
				sigma[j] =sqrt(sigt);
			}
		}
	}
	re = bestfit;//bpecDEbest1bin_rand_g(temp_lfsr,iternum,tfnum);


	for(int i=0;i<SIZE;i++){
//		re = bestfit;
		*(B+i)=re;
	}


}
