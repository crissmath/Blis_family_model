% script to test
% clc
% clear
% close all

%% var_blis = 'B3C2A0';
m = 1024;
n = 1024;
k = 1024;

MR = 4;
NR = 4; % 4,8,12,16,24 --> second dimension variation 
KR = 4; %  4,8,12,16,24 --> first variation 

%% elseif var_blis == 'B3A2C0'
    fprintf(" **** B3A2C0 ****\n");
    % get parameters : mc, nc, kc
    [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
    Mem_L3_use] = mem_model_gap8('B3A2C0', m, n, k, MR, NR, KR);

    % model
    [PackBc, PackAc, CopyBr, StreamAc, StreamBr, StreamCr, ...
    BrmemL1, BcmemL3, AcmemL2 ] = gemm_blis_B3A2C0( m, n, k, MC, NC, KC, MR, NR);
%% 

%% if var_blis == 'B3C2A0'
    fprintf(" **** B3C2A0 ****\n");    
    % get parameters : mc, nc, kc
    [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
    Mem_L3_use] = mem_model_gap8('B3C2A0', m, n, k, MR, NR, KR);

    %model
    [PackBc, PackCc, UnpackCc, CopyBr, StreamAr, StreamBr, StreamCr, ...
    BrmemL1, BcmemL3, CcmemL2 ] = gemm_blis_B3C2A0( m, n, k, MC, NC, KC, MR, KR);

%% elseif var_blis == 'C3B2A0'
    fprintf(" **** C3B2A0 ****\n");
    % Get parameters : mc, nc, kc
    [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
    Mem_L3_use] = mem_model_gap8('C3B2A0', m, n, k, MR, NR, KR);
        
    % model  
    [PackBc, PackCc, UnpackCc, CopyCr, StreamAr, StreamBc, StreamCc, ...
    CrmemL1, CcmemL3, BcmemL2 ] = gemm_blis_C3B2A0( m, n, k, MC, NC, KC, MR, KR );
%% end
 





