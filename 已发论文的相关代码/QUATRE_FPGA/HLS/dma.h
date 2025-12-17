#include <stdio.h>
#include<hls_stream.h>
#include <ap_int.h>
#include <ap_fixed.h>
#include <cstring>


#ifndef _DMA_H
#define _DMA_H

#define F 0.4

#define ps 100
#define MAXINTERATION 500
#define D 2

void mm2s(float* axi_rd,hls::stream<float> &axis_mm2s,int tx_len);

void s2mm(float* axi_wr,hls::stream<float> &axis_s2mm,int rx_len);

float evalfunc(float parameter[], int FUNC);

float pseudo_random(unsigned int seed, ap_uint<1> load);

unsigned int random_inter(unsigned int seed, ap_uint<1> load);

void Rand_Seq_Integer(unsigned int Rand_Seq[ps]);

void Rand_Label(bool label[D], unsigned int N);

void initialize(float X[][D], float val[ps], float &gbest_val, float gbest[D],float lb, float ub, int func, unsigned int seed);

void UpdateGbest(float Pbest[][D], float pbest_val[ps], float gbest[D], float &gbest_val);

void axi_dma(int FUNC,unsigned int seed, int &Iteration, float* result,hls::stream<float> axis_mm2s,hls::stream<float> axis_s2mm);

#endif
