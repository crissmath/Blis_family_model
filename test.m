% script to test
clc
clear all
close all

vart_blis = 1;
n_kernels = 3;  

m = 1792;
n = 1536;
k = 1024;

MR = 4;
KR = 4;

if vart_blis == 0
    fprintf(" **** B3C2A0 ****\n");
    for F=1:n_kernels
        if F == 1
            MC = 128; NC = 2048; KC = 1024;
        elseif F == 2
            MC = 256; NC = 1024; KC = 2048;
        elseif F == 3
            MC = 384; NC = 682;  KC = 3072;
        end    
        [PackBc, PackCc, UnpackCc, CopyBr, StreamAr, StreamBr, StreamCr, ...
        BrmemL1, BcmemL3, CcmemL2 ] = gemm_blis_B3C2A0( m, n, k, MC, NC, KC, MR, KR*F );
    end
elseif vart_blis == 1
    fprintf(" **** C3B2A0 ****\n");
    m = 1024;
    k = 1792;
    for F=1:n_kernels 
        if F == 1
            MC = 1024; NC = 2048; KC = 128;
        elseif F == 2
            MC = 2048; NC = 1024; KC = 256;
        elseif F == 3
            MC = 3072; NC = 682;  KC = 384;
        end
        [PackBc, PackCc, UnpackCc, CopyCr, StreamAr, StreamBr, StreamCr, ...
        BrmemL1, BcmemL3, CcmemL2 ] = gemm_blis_C3B2A0( m, n, k, MC, NC, KC, MR, KR*F );
    end    
else 
    fprintf(" Please select a variant !!\n");
    fprintf(" 0. B3C2A0\n");
    fprintf(" 1. C3B2A0\n");
    fprintf(" -------------------------------");
end 
