% script to test
% clc
% clear
% close all

%% var_blis = 'B3C2A0';
var_blis = 'C3B2A0';

m = 1792;
n = 1536;
k = 1024;

MR = 4;
KR = 4 ;
NR = 4;

%% if var_blis == 'B3C2A0'
    fprintf(" **** B3C2A0 ****\n");
        if MR==4 && KR==4 
            MC = 128; NC = 2048; KC = 1024;
        elseif MR==4 && KR==8
            MC = 256; NC = 1024; KC = 2048;
        elseif MR==4 && KR==12
            MC = 384; NC = 682;  KC = 3072;
        end    
        %% MC = 128; NC = 128; KC = 128;
        [PackBc, PackCc, UnpackCc, CopyBr, StreamAr, StreamBr, StreamCr, ...
         BrmemL1, BcmemL3, CcmemL2 ] = gemm_blis_B3C2A0( m, n, k, MC, NC, KC, MR, KR);
%% elseif var_blis == 'C3B2A0'
    fprintf(" **** C3B2A0 ****\n");
        if MR==4 && KR==4 
            MC = 1024; NC = 2048; KC = 128;
        elseif MR==4 && KR==8
            MC = 2048; NC = 1024; KC = 256;
        elseif MR==4 && KR==12
            MC = 3072; NC = 682;  KC = 384;
        end
        %% MC = 128; NC = 128; KC = 128;
        [PackBc, PackCc, UnpackCc, CopyCr, StreamAr, StreamBc, StreamCc, ...
         CrmemL1, CcmemL3, BcmemL2 ] = gemm_blis_C3B2A0( m, n, k, MC, NC, KC, MR, KR );
%% elseif var_blis == 'A3B2C0'
    fprintf(" **** A3B2C0 ****\n");
        if MR==4 && KR==4 
            MC = 1024; NC = 128; KC = 2048;
        elseif MR==4 && KR==8
            MC = 2048; NC = 256; KC = 1024;
        elseif MR==4 && KR==12
            MC = 3072; NC = 384;  KC = 682;
        end
        %% MC = 128; NC = 128; KC = 128;
        [PackBc, PackAc, UnpackAc, CopyAr, StreamAr, StreamBc, StreamCc, ...
        ArmemL1, AcmemL3, BcmemL2 ] = gemm_blis_A3B2C0( m, n, k, MC, NC, KC, MR, KR, NR);
%% end 

