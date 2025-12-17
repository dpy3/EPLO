############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 1986-2017 Xilinx, Inc. All Rights Reserved.
############################################################
set_directive_pipeline "evalfunc/func_1"
set_directive_pipeline "evalfunc/func_2"
set_directive_pipeline "evalfunc/func_3"
set_directive_pipeline "evalfunc/func_5"
set_directive_pipeline "evalfunc/func_4"
set_directive_pipeline -II 3 "Rand_Seq_Integer/RSI_1"
set_directive_unroll -factor 2 "Rand_Label/L_1"
set_directive_pipeline "Rand_Label/L_2"
set_directive_pipeline "initialize/init_1"
set_directive_unroll "initialize/init_1_1"
set_directive_unroll -factor 50 "initialize/init_val"
set_directive_pipeline "initialize/init_2"
set_directive_unroll -factor 2 "initialize/init_3"
set_directive_pipeline "UpdateGbest/UpGb_1"
set_directive_unroll -factor 2 "UpdateGbest/UpGb_2"
set_directive_interface -mode s_axilite -bundle CTRL_BUS "axi_dma"
set_directive_interface -mode s_axilite "axi_dma" FUNC
set_directive_interface -mode s_axilite "axi_dma" seed
set_directive_interface -mode s_axilite "axi_dma" Iteration
set_directive_interface -mode m_axi -depth 500 -offset slave -bundle MASTER_BUS "axi_dma" result
set_directive_unroll -factor 50 "axi_dma/QUATRE_l"
set_directive_pipeline "axi_dma/QUATRE_2"
set_directive_unroll "axi_dma/QUATRE_2_1"
set_directive_pipeline -II 13 "axi_dma/QUATRE_3_1"
set_directive_unroll "axi_dma/QUATRE_3_1_1"
set_directive_pipeline "axi_dma/QUATRE_label3"
