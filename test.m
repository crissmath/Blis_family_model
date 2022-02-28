% script to test 

m = 1792;
n = 1536;
k = 1024;

MC = 128;
NC = 2048;
KC = 1024;

MR = 4;
KR = 4;

% test kernel 4,8...24
for F=1:6 
    [PackBc, PackCc, UnpackCc, CopyBr, StreamAr, StreamBr, StreamCr, ...
    BrmemL1, BcmemL3, CcmemL2 ] = gemm_blis_B3C2A0( m, n, k, MC/F, NC/F, KC, MR, KR*F );
end