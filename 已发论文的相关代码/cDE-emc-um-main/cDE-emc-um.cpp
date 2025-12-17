#include <iostream>
#include <fstream>
#include <math.h>
#include<cstdlib>
#include<ctime>
#include <chrono>
using namespace std;
using std::chrono::high_resolution_clock;
using std::chrono::milliseconds;


#define N 10
#define PI 3.1415926535897932384626433832795029
#define GenNUM 25000*N
struct cDEin{
    int Tf_num; //测试函数
    // int GenMax;//迭代次数
    int Np;//虚拟种群的个体数�?
    // int Dim; //维度
    double F;
    double Cr;//参数
};

struct cDEout{
    double bestfit;
    double bestpop[N];
    double bestfithist[GenNUM];
};

// 全局变量
static double fitall_cde_rand[GenNUM];
static double fitall_cde_rand_2[GenNUM];
static double fitall_cde_rand_3[GenNUM];
static double fithist3[GenNUM];
static double fithist2[GenNUM];
static double fithist1[GenNUM];
cDEout coutput;
cDEout coutput2;
cDEout coutput3;
// 定义混沌函数
double chaos(double x) {
    double re = 3.3 * x * (1 - x);
    return re;
}
double chaos_map(double chaos_x,int Rmin,int Rmaxmin){
    double re;
    re = chaos_x*Rmaxmin+Rmin;
    // double rec = chaos_x*10000;
    // double re;
    // re = int(rec)%Rmaxmin+Rmin;
    // printf("%d ",re);
    return re;
}
int LFSRfunc(int seed,int Rmin,int Rmaxmin){
    int lfsr = seed; //static 
    int bit;
    bit = ((lfsr >> 0) ^ (lfsr >> 1) ^ (lfsr >> 2) ^ (lfsr >> 3)) & 1;
    lfsr = (lfsr >> 1) | (bit << 15);
    return lfsr;
}
        
//erf函数

// double myerfinv02(double x){
//     double x2log,t,p,rer;
//     x2log=log(1-x*x);
//     t=4.33074675+x2log/2;
//     p=x2log/0.147;
//     rer = sqrt(sqrt(t*t-p)-t);
//     return rer;
// }
double myerfinv03(double x){
    double temp,re;
    temp = x+0.261799388*x*x*x+0.143931731*x*x*x*x*x+0.097663620*x*x*x*x*x*x*x+0.073299079*x*x*x*x*x*x*x*x*x+0.058372501*x*x*x*x*x*x*x*x*x*x*x+0.048336063*x*x*x*x*x*x*x*x*x*x*x*x*x+0.041147395*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x;
    re = temp*(sqrt(PI)/2);
    return re;

}
double myerf01(double x){
    double a1=0.278393,a2=0.230389,a3=0.000972,a4=0.078108;
    double t,rer;
    double txx,ttt;
    txx=x*x;
    t= 1+a1*x+a2*txx+a3*txx*x+a4*txx*txx;
    ttt = t*t;
    rer=1-1/(ttt*ttt);

    return rer;
}
double generateCDFInv(double r,double mu,double tempsqr){
    double erfA,erfB,samplerand;

    erfA = myerf01((mu+1)/(tempsqr));
    erfB = myerf01((mu-1)/(tempsqr));
    samplerand = myerfinv03(-erfA-r*erfB+r*erfA)*tempsqr+mu;
    return samplerand;
}

// unimodal
double fitfunc_sphere(double pop[N]){
    double re=0;
    for(int i=0;i<N;i++){
        re = re+pop[i]*pop[i];
    }
    return re;
}
double fitfunc_BentCigar(double pop[N]){
    double re=0;
    re=re+pop[0]*pop[0];
    for(int i=1;i<N;i++){
        
        re = re+1000000*pop[i]*pop[i];
    }
    return re;
}
double fitfunc_Discus(double pop[N]){
    double re=0;
    re=re+1000000*pop[0]*pop[0];
    for(int i=1;i<N;i++){
        
        re = re+pop[i]*pop[i];
    }
    return re;
}
double fitfunc_Rosenbrock(double pop[N]){
    double re=0;
    for(int i=0;i<N-1;i++){
        
        re = re+100*(pop[i]*pop[i]-pop[i+1]*pop[i+1])*(pop[i]*pop[i]-pop[i+1]*pop[i+1])+(pop[i]-1)*(pop[i]-1);
    }
    return re;
}

// multimodal
double fitfunc_HGBat(double pop[N]){
    double re=0,temp1=0,temp2=0;
    for(int i=0;i<N;i++){
        temp1=temp1+pop[i]*pop[i];
        temp2=temp2+pop[i];
    }
    re = sqrt(abs(re+ temp1*temp1-temp2*temp2))+(0.5*temp1+temp2)/N+0.5;
    return re;
}
double fitfunc_Rastrigin(double pop[N]){
    double re = 0,temp=0;
    for(int i=0;i<N;i++){
        temp = temp+ pop[i]*pop[i]-10*cos(2*PI*pop[i]);
    }
    re = temp+10*N;
    return re;
}
double fitfunc_Alpine1(double pop[N]){
    double re = 0;
    for(int i=0;i<N;i++){
        re = re+ abs(pop[i]*sin(pop[i])+0.1*pop[i]);
    }
    return re;
}
double fitfunc_Griewank(double pop[N]){
    double re = 0,temp1=0,temp2=1;
    for(int i=0;i<N;i++){
        temp1=temp1+pop[i]*pop[i];
        temp2 = temp2*cos(pop[i]/sqrt(i+1));
    }
    re = re+ temp1/4000-temp2+1;
    return re;
}


//测试函数
int test_func_max(int func_num){
    int Rmax =0;
    if(func_num==1){ Rmax=100;}
    if(func_num==2){ Rmax=100;}
    if(func_num==3){ Rmax=100;}
    if(func_num==4){ Rmax=30;}
    if(func_num==5){ Rmax=100;}
    if(func_num==6){ Rmax=5.12;;}
    if(func_num==7){ Rmax=10;}
    if(func_num==8){ Rmax=100;}
    return Rmax;
}
int test_func_min(int func_num){
    int Rmin =0;
    if(func_num==1){ Rmin=-100;}
    if(func_num==2){ Rmin=-100;}
    if(func_num==3){ Rmin=-100;}
    if(func_num==4){ Rmin=-30;}
    if(func_num==5){ Rmin=-100;}
    if(func_num==6){ Rmin=-5.12;}
    if(func_num==7){ Rmin=-10;}
    if(func_num==8){ Rmin=-100;}
    return Rmin;
}
double test_func(double pop[N],int func_num){
    double re = 0;
    if(func_num==1){re = fitfunc_sphere(pop);}
    if(func_num==2){re = fitfunc_BentCigar(pop);}
    if(func_num==3){re = fitfunc_Discus(pop);}
    if(func_num==4){re = fitfunc_Rosenbrock(pop);}
    if(func_num==5){re = fitfunc_HGBat(pop);}
    if(func_num==6){re = fitfunc_Rastrigin(pop);}
    if(func_num==7){re = fitfunc_Alpine1(pop);}
    if(func_num==8){re = fitfunc_Griewank(pop);}
    return re;
}



// 原始DE
cDEout pecDErand1bin_rand(cDEin &cinput){
    cDEout coutput;
    // 定义变量
    double mu[N],sigma[N],mut,sigt;
    double best[N],winner[N],loser[N];
    double bestfit,xofffit;
    double los_l,win_l;
    double xr[N],xs[N],xt[N],xoff[N];

    double F,Cr;
    int Itermax,func_num,Np;
    double rand_x;
    double tempsqr; // 要有初始随机数种�?
    int Rmin,Rmax,Rmaxmin,Rmed;
    // 初始�?
    F= 0.7;//cinput.F;
    Cr = 0.9;//cinput.Cr;
    Itermax=GenNUM;
    func_num = cinput.Tf_num;
    Np = cinput.Np;
    Rmax = test_func_max(func_num);
    Rmin = test_func_min(func_num);
    Rmed = 0.5*(Rmax+Rmin);
    Rmaxmin = Rmax-Rmin;
    
    // srand(time(0));//设置随机数种�?
    for(int i=0;i<N;i++){
        mu[i] = 0;
        sigma[i] = 10;
        // rand_x = chaos(rand_x);
        // best[i] = chaos_map(rand_x,Rmin,Rmaxmin);
        best[i] = double(Rmin+rand()%(Rmaxmin+1));//chaos_map(rand_x,Rmin,Rmaxmin);
        xr[i] = 0;
        xt[i] = 0;
        xs[i] = 0;
        winner[i] = 0;
        loser[i] = 0;
    }
    bestfit = test_func(best,func_num);
    // printf("\nbegin: %lf \n",bestfit);
    fithist1[0] =bestfit;
    for(int i=1;i<Itermax;i++){
        // 变异
        for(int j=0;j<N;j++){
            // rand_x = chaos(rand_x);
            rand_x = rand()/double(RAND_MAX);// 随机数生�?
            tempsqr = sigma[j]*1.414213562;
            xr[j] = generateCDFInv(rand_x,mu[j],tempsqr)*0.5*Rmaxmin+Rmed;// 转换到决策域
            // rand_x = chaos(rand_x);
            rand_x = rand()/double(RAND_MAX);// 随机数生�?
            xt[j] = generateCDFInv(rand_x,mu[j],tempsqr)*0.5*Rmaxmin+Rmed;// 转换到决策域
            // rand_x = chaos(rand_x);
            rand_x = rand()/double(RAND_MAX);// 随机数生�?
            xs[j] = generateCDFInv(rand_x,mu[j],tempsqr)*0.5*Rmaxmin+Rmed;// 转换到决策域
        }
        for(int j=0;j<N;j++){
            xoff[j] =xt[j]+F*(xr[j]-xs[j]);
            if(xoff[j]>Rmax){xoff[j]=Rmax;}
            if(xoff[j]<Rmin){xoff[j]=Rmin;} //这种方法会不断地跳到边界，然后无法收�?
            // if(xoff[j]>Rmax){xoff[j]=double(Rmin+rand()%(Rmaxmin+1));}
            // if(xoff[j]<Rmin){xoff[j]=double(Rmin+rand()%(Rmaxmin+1));}
        }
        // 交叉
        for(int j=0;j<N;j++){
            // rand_x = chaos(rand_x);
            rand_x = rand()/double(RAND_MAX);// 随机数生�?
            if(rand_x>Cr){
                xoff[j] = best[j];
            }
        }
        xofffit = test_func(xoff,func_num);
        // 评估winner loser
        if(xofffit<bestfit){
            for(int j=0;j<N;j++){
                best[j] = xoff[j];
            }
            bestfit = xofffit;
        }
        if(xofffit<=bestfit){
            for(int j=0;j<N;j++){
                winner[j] = xoff[j];
                loser[j] = best[j];
            }  
        }
        if(xofffit>bestfit){
            for(int j=0;j<N;j++){
                winner[j] = best[j];
                loser[j] = xoff[j];
            }
        }
        for(int j=0;j<N;j++){
            // 转换到PDF
            win_l = (winner[j]-Rmed)/(0.5*Rmaxmin);
            los_l = (loser[j]-Rmed)/(0.5*Rmaxmin);
            mut = mu[j];
            mu[j] = mu[j]+(win_l-los_l)/Np;
            sigt = sigma[j]*sigma[j]+mut*mut-mu[j]*mu[j]+(win_l*win_l-los_l*los_l)/Np;
            if(sigt<=0){
                sigma[j] =10;// 不能等于0 否则就陷入局部最优了
            }
            else{
                sigma[j] =sqrt(sigt);
            }
        }
        fithist1[i] =bestfit;
    }
    coutput.bestfit = bestfit;
    for(int j=0;j<N;j++){
        coutput.bestpop[j] = best[j];
    }
    for(int j=0;j<GenNUM;j++){
        coutput.bestfithist[j] = fithist1[j];
    }
    return coutput;
}
//借用DE
cDEout pecDEumbest1bin_rand(cDEin &cinput){
    cDEout coutput;
    // 定义变量
    double mu[N],sigma[N],mut,sigt;
    double best[N],winner[N],loser[N];
    double bestfit,xofffit;
    double los_l,win_l;
    double xr[N],xs[N],xt[N],xoff[N];

    double F,Cr;
    int Itermax,func_num,Np;
    double rand_x,rand_x1,rand_x2,rand_x3,rand_x4,rand_x5;
    double tempsqr; // 要有初始随机数种�?
    int Rmin,Rmax,Rmaxmin,Rmed;
    double erf1,erf2,sigF;
    // 初始�?
    F= 0.7;//cinput.F;
    Cr = 0.9;//cinput.Cr;
    Itermax=GenNUM;
    func_num = cinput.Tf_num;
    Np = cinput.Np;
    Rmax = test_func_max(func_num);
    Rmin = test_func_min(func_num);
    Rmed = 0.5*(Rmax+Rmin);
    Rmaxmin = Rmax-Rmin;
    
    // srand(time(0));//设置随机数种�?
    for(int i=0;i<N;i++){
        mu[i] = 0;
        sigma[i] = 10;
        // rand_x = chaos(rand_x);
        // best[i] = chaos_map(rand_x,Rmin,Rmaxmin);
        best[i] = double(Rmin+rand()%(Rmaxmin+1));//chaos_map(rand_x,Rmin,Rmaxmin);
        xr[i] = 0;
        xt[i] = 0;
        xs[i] = 0;
        winner[i] = 0;
        loser[i] = 0;
    }
    bestfit = test_func(best,func_num);
    // printf("\nbegin: %lf \n",bestfit);
    fithist2[0] =bestfit;
    for(int i=1;i<Itermax;i++){
        // 变异
        for(int j=0;j<N;j++){
            rand_x1 = rand()/double(RAND_MAX);// 随机数生�?
            rand_x2 = rand()/double(RAND_MAX);// 随机数生�?
            rand_x3 = rand()/double(RAND_MAX);// 随机数生�?
            rand_x4 = rand()/double(RAND_MAX);// 随机数生�?
            rand_x5 = rand()/double(RAND_MAX);// 随机数生�?
            tempsqr = sigma[j]*1.414213562;
            erf1 = myerf01((mu[j]-1)/(tempsqr));
            erf2 = myerf01((mu[j]+1)/(tempsqr));
            sigF = 1.414213562*F*sigma[j];

            xoff[j] =mu[j] +tempsqr*myerfinv03(-rand_x1*erf1+(rand_x1-1)*erf2)+F*(((best[j]-Rmed)/(0.5*Rmaxmin))-mu[j]-tempsqr*myerfinv03(-rand_x1*erf1+(rand_x1-1)*erf2))+((rand()/double(RAND_MAX))-0.5);
            // xoff[j] =mu[j] +tempsqr*myerfinv03(-rand_x1*erf1+(rand_x1-1)*erf2)+sigF*myerfinv03(-rand_x2*erf1+(rand_x2-1)*erf2)-sigF*myerfinv03(-rand_x3*erf1+(rand_x3-1)*erf2)+((rand()/double(RAND_MAX))-0.5);
            // xoff[j] =xoff[j]*0.5*Rmaxmin+Rmed+rand_x1*(double(Rmin+rand()%(Rmaxmin+1)-double(Rmin+rand()%(Rmaxmin+1))));
            // xoff[j] =xoff[j]*0.5*Rmaxmin+Rmed+(rand_x1-0.5)*0.5*Rmaxmin+Rmed;//(double(Rmin+rand()%(Rmaxmin+1)-double(Rmin+rand()%(Rmaxmin+1))));
            xoff[j] =xoff[j]*0.5*Rmaxmin+Rmed;//+(rand_x1-0.5)*0.5*Rmaxmin+Rmed;
            
        }
        for(int j=0;j<N;j++){
            // xoff[j] =xt[j]+F*(xr[j]-xs[j]);
            if(xoff[j]>Rmax){xoff[j]=Rmax;}
            if(xoff[j]<Rmin){xoff[j]=Rmin;} //这种方法会不断地跳到边界，然后无法收�?
            // if(xoff[j]>Rmax){xoff[j]=double(Rmin+rand()%(Rmaxmin+1));}
            // if(xoff[j]<Rmin){xoff[j]=double(Rmin+rand()%(Rmaxmin+1));}
        }
        // 交叉
        for(int j=0;j<N;j++){
            // rand_x = chaos(rand_x);
            rand_x = rand()/double(RAND_MAX);// 随机数生�?
            if(rand_x>Cr){
                xoff[j] = best[j];
            }
        }
        xofffit = test_func(xoff,func_num);
        // 评估winner loser
        if(xofffit<bestfit){
            for(int j=0;j<N;j++){
                best[j] = xoff[j];
            }
            bestfit = xofffit;
        }
        if(xofffit<=bestfit){
            for(int j=0;j<N;j++){
                winner[j] = xoff[j];
                loser[j] = best[j];
            }  
        }
        if(xofffit>bestfit){
            for(int j=0;j<N;j++){
                winner[j] = best[j];
                loser[j] = xoff[j];
            }
        }
        for(int j=0;j<N;j++){
            // 转换到PDF
            win_l = (winner[j]-Rmed)/(0.5*Rmaxmin);
            los_l = (loser[j]-Rmed)/(0.5*Rmaxmin);
            mut = mu[j];
            mu[j] = mu[j]+(win_l-los_l)/Np;
            sigt = sigma[j]*sigma[j]+mut*mut-mu[j]*mu[j]+(win_l*win_l-los_l*los_l)/Np;
            if(sigt<=0){
                sigma[j] =10;// 不能等于0 否则就陷入局部最优了
            }
            else{
                sigma[j] =sqrt(sigt);
            }
        }
        fithist2[i] =bestfit;
    }
    coutput.bestfit = bestfit;
    for(int j=0;j<N;j++){
        coutput.bestpop[j] = best[j];
    }
    for(int j=0;j<GenNUM;j++){
        coutput.bestfithist[j] = fithist2[j];
    }
    return coutput;
}
// 改进DE
cDEout bpecDEbest1bin_rand_g(cDEin &cinput){
 cDEout coutput;
    // 定义变量
    double mu[N],sigma[N],mut,sigt;
    double best[N],winner[N],loser[N];
    double bestfit,xofffit;
    double los_l,win_l;
    double xr[N],xs[N],xt[N],xoff[N];
    
    double F,Cr;
    int Itermax,func_num,Np;
    double rand_x,rand_x1,rand_x2,rand_x3,rand_x4,rand_x5;
    double tempsqr; // 要有初始随机数种�?
    int Rmin,Rmax,Rmaxmin,Rmed;
    double erf1,erf2,sigF;
    // 初始�?
    F= 0.7;//cinput.F;
    Cr = 0.9;//cinput.Cr;
    Itermax=GenNUM;
    func_num = cinput.Tf_num;
    Np = cinput.Np;
    Rmax = test_func_max(func_num);
    Rmin = test_func_min(func_num);
    Rmed = 0.5*(Rmax+Rmin);
    Rmaxmin = Rmax-Rmin;
    
    
    for(int i=0;i<N;i++){
        mu[i] = 0;
        sigma[i] = 10;
        // rand_x = chaos(rand_x);
        // best[i] = chaos_map(rand_x,Rmin,Rmaxmin);
        best[i] = double(Rmin+rand()%(Rmaxmin+1));//chaos_map(rand_x,Rmin,Rmaxmin);
        xr[i] = 0;
        xt[i] = 0;
        xs[i] = 0;
        winner[i] = 0;
        loser[i] = 0;
    }
    bestfit = test_func(best,func_num);
    // printf("\nbegin: %lf \n",bestfit);
    fithist3[0] =bestfit;
    for(int i=1;i<Itermax;i++){
        // 变异
        for(int j=0;j<N;j++){
            // rand_x = chaos(rand_x);
            tempsqr = sigma[j]*1.414213562;
            erf1 = myerf01((mu[j]-1)/(tempsqr));
            erf2 = myerf01((mu[j]+1)/(tempsqr));
            sigF = 1.414213562*F*sigma[j];
            rand_x1 = rand()/double(RAND_MAX);// 随机数生�?
            rand_x2 =rand()/double(RAND_MAX);
            
            
            if(rand_x2>((Cr-0.7)*(i/Itermax)+0.7)){
                xoff[j] = (F+(i/Itermax)*0.2)*(((best[j]-Rmed)/(0.5*Rmaxmin))-mu[j])+mu[j]-tempsqr*((F+(i/Itermax)*0.2)-1)*myerfinv03(-rand_x1*erf1+(rand_x1-1)*erf2)+(rand_x2-0.5);
            }
            else{
                xoff[j] = (best[j]-Rmed)/(0.5*Rmaxmin);
            }
            // xoff[j] =mu[j] +tempsqr*myerfinv03(-rand_x1*erf1+(rand_x1-1)*erf2)+(F+(i/Itermax)*0.2)*(((best[j]-Rmed)/(0.5*Rmaxmin))-mu[j]-tempsqr*myerfinv03(-rand_x1*erf1+(rand_x1-1)*erf2))+((rand()/double(RAND_MAX))-0.5);
            // xoff[j] =mu[j] +tempsqr*myerfinv03(-rand_x1*erf1+(rand_x1-1)*erf2)+sigF*myerfinv03(-rand_x2*erf1+(rand_x2-1)*erf2)-sigF*myerfinv03(-rand_x3*erf1+(rand_x3-1)*erf2)+((rand()/double(RAND_MAX))-0.5);
            // xoff[j] =xoff[j]*0.5*Rmaxmin+Rmed+rand_x1*(double(Rmin+rand()%(Rmaxmin+1)-double(Rmin+rand()%(Rmaxmin+1))));
            // xoff[j] =xoff[j]*0.5*Rmaxmin+Rmed+(rand_x1-0.5)*0.5*Rmaxmin+Rmed;//(double(Rmin+rand()%(Rmaxmin+1)-double(Rmin+rand()%(Rmaxmin+1))));
            xoff[j] =xoff[j]*0.5*Rmaxmin+Rmed;//+(rand_x1-0.5)*0.5*Rmaxmin+Rmed;
            // xt[j] = generateCDFInv(rand_x,mu[j],tempsqr)*0.5*Rmaxmin+Rmed;// 转换到决策域
            // // // rand_x = chaos(rand_x);
            // rand_x = rand()/double(RAND_MAX);// 随机数生�?
            // xr[j] = generateCDFInv(rand_x,mu[j],tempsqr)*0.5*Rmaxmin+Rmed;// 转换到决策域
            // // rand_x = chaos(rand_x);
            // rand_x = rand()/double(RAND_MAX);// 随机数生�?
            // xs[j] = generateCDFInv(rand_x,mu[j],tempsqr)*0.5*Rmaxmin+Rmed;// 转换到决策域
            // // xr[j] = generateCDFInv(rand_x,(1+F)*mu[j],(sigma[j]*sigma[j]+1)*1.414213562)*0.5*Rmaxmin+Rmed;// 转换到决策域
            // xoff[j] = generateCDFInv(rand_x,mu[j],(sigma[j]*sigma[j]*(1+2*F*F))*1.414213562)*0.5*Rmaxmin+Rmed;// 转换到决策域
            // xs[j] = double(Rmin+rand()%(Rmaxmin+1));// 转换到决策域
            // xoff[j] =xt[j]+F*(xr[j]-xs[j]);
            // xoff[j] =xs[j];
            if(xoff[j]>Rmax){xoff[j]=Rmax;}
            if(xoff[j]<Rmin){xoff[j]=Rmin;} //这种方法会不断地跳到边界，然后无法收�?
            // if(xoff[j]>Rmax){xoff[j]=double(Rmin+rand()%(Rmaxmin+1));}
            // if(xoff[j]<Rmin){xoff[j]=double(Rmin+rand()%(Rmaxmin+1));}
            // if(xoff[j]>Rmax){rand_x = rand()/double(RAND_MAX);xoff[j]=generateCDFInv(rand_x,mu[j],tempsqr)*0.5*Rmaxmin+Rmed;}
            // if(xoff[j]<Rmin){rand_x = rand()/double(RAND_MAX);xoff[j]=generateCDFInv(rand_x,mu[j],tempsqr)*0.5*Rmaxmin+Rmed;}
        }
        // for(int j=0;j<N;j++){
            
        // }
        // 交叉
        
        // for(int j=0;j<N;j++){
        //     // rand_x = chaos(rand_x);
        //     rand_x = rand()/double(RAND_MAX);// 随机数生�?
        //     if(rand_x>Cr){
        //     // if(j<rand_x*N){
        //         xoff[j] = best[j];
        //     }
        // }
        xofffit = test_func(xoff,func_num);
        // 评估winner loser
        if(xofffit<bestfit){
            for(int j=0;j<N;j++){
                best[j] = xoff[j];
            }
            bestfit = xofffit;
        }
        if(xofffit<=bestfit){
            for(int j=0;j<N;j++){
                winner[j] = xoff[j];
                loser[j] = best[j];
            }  
        }
        if(xofffit>bestfit){
            for(int j=0;j<N;j++){
                winner[j] = best[j];
                loser[j] = xoff[j];
            }
        }
        for(int j=0;j<N;j++){
            // 转换到PDF
            win_l = (winner[j]-Rmed)/(0.5*Rmaxmin);
            los_l = (loser[j]-Rmed)/(0.5*Rmaxmin);
            mut = mu[j];
            mu[j] = mu[j]+(win_l-los_l)/Np;
            sigt = sigma[j]*sigma[j]+mut*mut-mu[j]*mu[j]+(win_l*win_l-los_l*los_l)/Np;
            if(sigt<=0){
                sigma[j] =10;// 不能等于0 否则就陷入局部最优了
            }
            else{
                sigma[j] =sqrt(sigt);
            }
        }
        fithist3[i] =bestfit;
    }
    coutput.bestfit = bestfit;
    for(int j=0;j<N;j++){
        coutput.bestpop[j] = best[j];
    }
    for(int j=0;j<GenNUM;j++){
        coutput.bestfithist[j] = fithist3[j];
    }
    return coutput;
}


int main(){
    
    // int Func_all_num = 8;
    // for(int i=0;i<Func_all_num;i++){
        printf("begin %d\n",GenNUM);
        srand(time(0));//设置随机数种�?
        ofstream file_histfit_cde_rand,file_fit_cde_rand;
        // 不同函数改进版本
        
        double fitall_best_cde_rand[51];
        
        double fitall_best_cde_rand_2[51];
        double fitall_best_cde_rand_3[51];
        file_histfit_cde_rand.open("file_histfit_cde.txt");
        file_fit_cde_rand.open("file_fit_cde.txt");
        for(int j=0;j<GenNUM;j++){fitall_cde_rand[j]=0;}
        for(int j=0;j<GenNUM;j++){fitall_cde_rand_2[j]=0;}
        for(int j=0;j<GenNUM;j++){fitall_cde_rand_3[j]=0;}
        cDEin cinput;
        cinput.Cr = 0.7;
        cinput.F = 0.7;
        // cinput.GenMax = GenNUM;
        cinput.Tf_num = 8;
        cinput.Np = 10;
        high_resolution_clock::time_point beginTime1 = high_resolution_clock::now();
        for(int i=0;i<51;i++){
            //第一�?
            coutput = pecDErand1bin_rand(cinput);
            fitall_best_cde_rand[i] = coutput.bestfit;
            for(int j=0;j<GenNUM;j++){
                fitall_cde_rand[j] = fitall_cde_rand[j]+coutput.bestfithist[j];
            }
           
        }
        high_resolution_clock::time_point endTime1 = high_resolution_clock::now();
        milliseconds timeInterval1 = std::chrono::duration_cast<milliseconds>(endTime1 - beginTime1);
        cout << "Running Time 1:" << timeInterval1.count()  << "ms" << endl;
        high_resolution_clock::time_point beginTime2 = high_resolution_clock::now();
        for(int i=0;i<51;i++){
         //第二�? 直接借用
            coutput2 = pecDEumbest1bin_rand(cinput);
            fitall_best_cde_rand_2[i] = coutput2.bestfit;
            for(int j=0;j<GenNUM;j++){
                fitall_cde_rand_2[j] = fitall_cde_rand_2[j] +coutput2.bestfithist[j];
            }
        }
        high_resolution_clock::time_point endTime2 = high_resolution_clock::now();
        milliseconds timeInterval2 = std::chrono::duration_cast<milliseconds>(endTime2 - beginTime2);
        cout << "Running Time 2:" << timeInterval2.count()  << "ms" << endl;
        high_resolution_clock::time_point beginTime3 = high_resolution_clock::now();
        for(int i=0;i<51;i++){
            // 第三�? 借用后改�?
            coutput3 = bpecDEbest1bin_rand_g(cinput);
            fitall_best_cde_rand_3[i] = coutput3.bestfit;
            for(int j=0;j<GenNUM;j++){
                fitall_cde_rand_3[j] = fitall_cde_rand_3[j] +coutput3.bestfithist[j];
            }
            // printf("Test %d\n",i);
        }
        high_resolution_clock::time_point endTime3 = high_resolution_clock::now();
        milliseconds timeInterval3 = std::chrono::duration_cast<milliseconds>(endTime3 - beginTime3);
        cout << "Running Time 3:" << timeInterval3.count()  << "ms" << endl;
            
        // �?优�??
        for(int j=0;j<51;j++){ file_fit_cde_rand <<fitall_best_cde_rand[j]<<" ";}
        file_fit_cde_rand<<endl;
        for(int j=0;j<51;j++){ file_fit_cde_rand <<fitall_best_cde_rand_2[j]<<" ";}
        file_fit_cde_rand<<endl;
        for(int j=0;j<51;j++){ file_fit_cde_rand <<fitall_best_cde_rand_3[j]<<" ";}
        file_fit_cde_rand<<endl;

        //收敛曲线
        for(int j=0;j<GenNUM;j++){file_histfit_cde_rand <<fitall_cde_rand[j]/51<<" ";}
        file_histfit_cde_rand <<endl;
        for(int j=0;j<GenNUM;j++){file_histfit_cde_rand <<fitall_cde_rand_2[j]/51<<" ";}
        file_histfit_cde_rand <<endl;
        for(int j=0;j<GenNUM;j++){file_histfit_cde_rand <<fitall_cde_rand_3[j]/51<<" ";}
        file_histfit_cde_rand <<endl;

        file_fit_cde_rand.close();
        file_histfit_cde_rand.close();
    // }
    return 0;
}
