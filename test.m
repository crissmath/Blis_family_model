% script to test
clc
clear all
close all

vart_blis = 0;

n_kernels =1;

m = 1792;
n = 1536;
k = 1024;

MC = 128;
NC = 2048;
KC = 1024;

MR = 4;
KR = 4;

if vart_blis == 0
    fprintf(" **** B3C2A0 ****\n");
    for F=1:n_kernels  
        [PackBc, PackCc, UnpackCc, CopyBr, StreamAr, StreamBr, StreamCr, ...
        BrmemL1, BcmemL3, CcmemL2 ] = gemm_blis_B3C2A0( m, n, k, MC, NC, KC, MR, KR*F );
    end
elseif vart_blis == 1
    fprintf(" **** C3B2A0 ****\n");
    for F=1:n_kernels 
        [PackBc, PackCc, UnpackCc, CopyCr, StreamAr, StreamBr, StreamCr, ...
        BrmemL1, BcmemL3, CcmemL2 ] = gemm_blis_C3B2A0( m, n, k, MC, NC, KC, MR, KR*F );
    end    
else 
    fprintf(" Please select a variant !!\n");
    fprintf(" 0. B3C2A0\n");
    fprintf(" 1. C3B2A0\n");
    fprintf(" -------------------------------");
end 
