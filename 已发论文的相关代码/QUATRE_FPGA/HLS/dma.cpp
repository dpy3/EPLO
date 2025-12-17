#include "dma.h"

void mm2s(float* axi_rd,hls::stream<float> &axis_mm2s,int tx_len){
	for(int i=0;i<tx_len;i++){
#pragma HLS PIPELINE
		float tmp=*(axi_rd+i);
		axis_mm2s<<tmp;
	}
}

void s2mm(float* axi_wr,hls::stream<float> &axis_s2mm,int rx_len){
    for(int i=0;i<rx_len;i++){
#pragma HLS PIPELINE
    	float tmp;
    	axis_s2mm>>tmp;
    	*(axi_wr+i)=tmp;
    }
}

float evalfunc(float parameter[], int FUNC)
{
	float val = 0.0;
	if(FUNC == 1)
	{	//Square Function
		func_1:for (int i = 0; i < D; i++)
		{
			val += parameter[i] * parameter[i];
		}
	}
	else if(FUNC == 2){
		//Schwefel's function 1.2
		func_2:for (int i = 0; i < D; i++)
		{
			float val2 = 0;
			func_2_1:for (int j = 0; j < i; j++)
			{
				val2 += parameter[j];
			}
			val += val2*val2;
		}
	}
	else if(FUNC == 3){
		//Schwefel's function 2.21
		float tmp = 1.0, tmp2;
		func_3:for(int i=0;i<D;i++){
			tmp2 = (parameter[i]<0)?(-parameter[i]):parameter[i];
			val += tmp2;
			tmp = tmp*tmp2;
		}
		val = val + tmp;
		return val;
	}
	else if(FUNC == 4){
		// Schwefel's function 2.22
		float tmp = -10000.0, tmp2;
		func_4:for(int i=0;i<D;i++){
			tmp2 = (parameter[i]<0)?(-parameter[i]):parameter[i];
			if(tmp2 > tmp)
				tmp = tmp2;
		}
		val = tmp;
	}

	else if(FUNC == 5){
		//Rosenbrock Function
		float tmp;
		func_5:for(int i=0;i<D-1;i++){
			tmp = parameter[i]*parameter[i]-parameter[i+1];
			val = val + 100*(tmp*tmp) + (parameter[i]-1)*(parameter[i]-1);
		}
	}
//	else if(FUNC == 6){
//		// STYBLINSKI-TANG FUNCTION
//		float tmp, tmp2, tmp3, tmp4;
//		func_6:for(int i=0;i<D;i++){
//			tmp = parameter[i]*parameter[i];
//			tmp2 = tmp*tmp;
//			tmp3 = 16*tmp;
//			tmp4 = 5*parameter[i];
//			val = val + tmp2 - tmp3 + tmp4;
//		}
//		val/=2;
//	}
//	else if(FUNC == 6){
//		//THREE-HUMP CAMEL FUNCTION
//		float tmp = parameter[0]*parameter[0];
//		float tmp2 = tmp*tmp;
//		float tmp3 = parameter[1]*parameter[1];
//		val = 2*tmp - 1.05*tmp2 + tmp2*tmp/6 + parameter[0]*parameter[1] + tmp3;
//
//	}
	else{
		//DIXON-PRICE FUNCTION
		float tmp = (parameter[0]-1)*(parameter[0]-1);
		float tmp2 = 2*parameter[1]*parameter[1]-parameter[0];
		val = tmp*tmp + 2*tmp2*tmp2;

	}
	return val;
}

float pseudo_random(unsigned int seed=65534, ap_uint<1> load = 0)
{
	static ap_uint<32> lfsr;
	ap_fixed<32,16> rand_num = 0.0;
	if (load == 1 )
	lfsr = seed;
	bool b_32 = lfsr.get_bit(32-32);
	bool b_22 = lfsr.get_bit(32-22);
	bool b_2 = lfsr.get_bit(32-2);
	bool b_1 = lfsr.get_bit(32-1);
	bool new_bit = b_32 ^ b_22 ^ b_2 ^ b_1;
	lfsr = lfsr >> 1;
	lfsr.set_bit(31, new_bit);
	// parallel
	rand_num[0] = lfsr[0];
	rand_num[1] = lfsr[1];
	rand_num[2] = lfsr[2];
	rand_num[3] = lfsr[3];
	rand_num[4] = lfsr[4];
	rand_num[5] = lfsr[5];
	rand_num[6] = lfsr[6];
	rand_num[7] = lfsr[7];
	rand_num[8] = lfsr[8];
	rand_num[9] = lfsr[9];
	rand_num[10] = lfsr[10];
	rand_num[11] = lfsr[11];
	rand_num[12] = lfsr[12];
	rand_num[13] = lfsr[13];
	rand_num[14] = lfsr[14];
	rand_num[15] = lfsr[15];
	lfsr = (lfsr[0]==1)?~lfsr:~(lfsr>>1);
	return (float)rand_num;
}

unsigned int random_inter(unsigned int seed=65534, ap_uint<1> load = 0)
{
	static ap_uint<32> lfsr1;
	if (load ==1 )
		lfsr1 = seed;
	bool b_32 = lfsr1.get_bit(32-32);
	bool b_22 = lfsr1.get_bit(32-22);
	bool b_2 = lfsr1.get_bit(32-2);
	bool b_1 = lfsr1.get_bit(32-1);
	bool new_bit = b_32 ^ b_22 ^ b_2 ^ b_1;
	lfsr1 = lfsr1 >> 1;
	lfsr1.set_bit(31, new_bit);

	return lfsr1.to_uint();
}

//Create Random Integer Sequence in [0,ps-1] for rand individual
void Rand_Seq_Integer(unsigned int Rand_Seq [ps])
{

	RSI_1:for (unsigned int i = ps - 1; i > 1; i--){
		unsigned int a = i;
		unsigned int b = random_inter()%(i-1);
		unsigned int tmp = Rand_Seq[a];
		Rand_Seq[a] = Rand_Seq[b];
		Rand_Seq[b] = tmp;
	}
	Rand_Seq[1] = Rand_Seq[1] ^ Rand_Seq[0];
	Rand_Seq[0] = Rand_Seq[1] ^ Rand_Seq[0];
	Rand_Seq[1] = Rand_Seq[1] ^ Rand_Seq[0];
	//swap(Rand_Seq[1], Rand_Seq[0]);

}
// Create N rand positions to be 1
void Rand_Label(bool label[D], unsigned int N)
{
//    int cnt = 0;
//    RL_1:while(cnt < N){
//        int val = random_inter()%D;
//        if(!label[val]){
//            label[val] = 1;
//            cnt++;
//        }
//    }
    int tmp[D];
	L_1:for(int i=0;i<D;i++)
		tmp[i] = i;
	int w;
	L_2:for(int i=0;i<N;i++){
		w=random_inter()%(D-i)+i;
		int tmpp = tmp[i];
		tmp[i] = tmp[w];
		tmp[w] = tmpp;
		label[tmp[i]] = 1;
	}

}

void initialize(float X[][D], float val[ps], float &gbest_val, float gbest[D],float lb, float ub, int func, unsigned int seed)
{
	float tmp1 = pseudo_random(seed, 1);
	unsigned tmp2 = random_inter(seed, 1);
    init_1:for(int i=0;i<ps;i++){
        init_1_1:for(int j=0;j<D;j++){
            X[i][j] = lb + (ub - lb)*pseudo_random();
        }
//        val[i] = evalfunc(X[i],func);
    }
    init_val:for(int i=0;i<ps;i++){
    	val[i] = evalfunc(X[i],func);
    }
    gbest_val = val[0];
    int index_i = 0;
    init_2:for(int i=1;i<ps;i++){
        if(gbest_val > val[i]){
            index_i = i;
            gbest_val = val[i];
        }
    }

    init_3:for(int i=0;i<D;i++){
        gbest[i] = X[index_i][i];
    }
}
void UpdateGbest(float Pbest[][D], float pbest_val[ps], float gbest[D], float &gbest_val)
{
    int flag = 0, index_i = 0;
    UpGb_1:for(int i=0;i<ps;i++){
        if(gbest_val > pbest_val[i]){
            flag = 1;
            index_i = i;
            gbest_val = pbest_val[i];
        }
    }
    if(flag == 1){
    	UpGb_2:for(int j=0;j<D;j++){
            gbest[j] = Pbest[index_i][j];
        }
    }
}

void axi_dma(int FUNC,unsigned int seed, int &Iteration, float* result,hls::stream<float> axis_mm2s,hls::stream<float> axis_s2mm)
{
	#pragma HLS STREAM variable=axis_s2mm depth=1024 dim=1
	#pragma HLS STREAM variable=axis_mm2s depth=1024 dim=1
	#pragma HLS INTERFACE axis register both port=axis_s2mm
	#pragma HLS INTERFACE axis register both port=axis_mm2s

	float ub,lb,best_val;
	    switch(FUNC){
	    case 1: ub = 5.12;lb = -5.12;best_val=0; break;
	    case 2: ub = 100;lb = -100;best_val=0; break;
	    case 3: ub = 10;lb = -10;best_val=0; break;
	    case 4: ub = 100;lb = -100;best_val=0; break;
	    case 5: ub = 2.048;lb = -2.048;best_val=0;break;
	//    case 6: ub = 5;lb = -5;best_val = -36.16599*D; break;
	//    case 6: ub = 5;lb = -5; best_val = 0; break;
	    default: ub = 10; lb = -10; best_val = 0; break;
	    }

		//
		float tmp[MAXINTERATION];
	    float gbest_val;
	    float gbest[D];
	    float X[ps][D];
	    float Pbest[ps][D];
	    float val[ps],pbest_val[ps];

	    unsigned int posr1[ps] = {0};
	    unsigned int posr2[ps] = {0};

	    QUATRE_l:for(int i=0;i<ps;i++){
	        posr1[i] = i;
	        posr2[i] = i;
	    }


	    initialize(X, val, gbest_val, gbest,lb, ub, FUNC, seed);
	    //cout<<gbest_val<<endl;
	    QUATRE_2:for(int i=0;i<ps;i++){
	        QUATRE_2_1:for(int j=0;j<D;j++){
	            Pbest[i][j] = X[i][j];
	        }
	        pbest_val[i] = val[i];
	    }
	//    int K = ps/D;
	//    int mod_cnt = ps%D;
	//    int one_sum = K*(D*(D+1)/2)+mod_cnt*(mod_cnt+1)/2;
	//    int cnt = one_sum/ps;
	    int cnt = 1;
	    int flag = 0;
	    //Main Loop
	    QUATRE_3:
	    for(int iter=1;iter<=MAXINTERATION;iter++){
	        Rand_Seq_Integer(posr1); // rand individual
	        Rand_Seq_Integer(posr2);
	        QUATRE_3_1:for(int i=0;i<ps;i++){
	        	bool label[D] = {0};
//	        	int cnt = random_inter()%(D/2)+1;//Create One Random Integer in [1,N] to decide how many position to be 1
	            Rand_Label(label,cnt);
	            QUATRE_3_1_1:for(int j=0;j<D;j++){
	            	float x = gbest[j]+F*(X[posr1[i]][j]-X[posr2[i]][j]);
	            	if(x > ub)
	            		x = ub;
	            	if(x < lb)
	            		x = lb;
	            	X[i][j] = (label[j]==1)?x:Pbest[i][j];
	            }
	        }
	        QUATRE_label3:for(int i=0;i<ps;i++){
	        	val[i] = evalfunc(X[i],FUNC);
				if(val[i] < pbest_val[i]){
					pbest_val[i] = val[i];
					QUATRE_3_1_2:for(int j=0;j<D;j++){
						Pbest[i][j] = X[i][j];
					}
				}
	        }
	        UpdateGbest(Pbest,pbest_val,gbest,gbest_val);
	        tmp[iter-1] = gbest_val;
	        //printf("Iteration: %d = actual gbest_val : %.5lf\n",iter, gbest_val);
	        result[iter-1] = gbest_val;
	        if(flag == 0 && gbest_val == best_val){
				Iteration = iter;
				flag = 1;
			}
	    }
	    //cout<<gbest_val<<endl;
	    if(flag == 0)
			Iteration = MAXINTERATION;

	    mm2s(&tmp[0],axis_mm2s,MAXINTERATION);
		s2mm(result,axis_s2mm,MAXINTERATION);

}
