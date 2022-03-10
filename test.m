% =======================================================
%                   Script to test
% =======================================================
%
% Config Parameters
%var_blis  = 'B3A2C0';
visual    = 1; % generate graphs
data      = 0; % generate data

%
% Matrix size 
m = 1792;
n = 1536;
k = 1024;

%
% micropanels size 
MR = 4;
NR = 4; %  4,8,12,16,24 --> second dimension variation 
KR = 4; %  4,8,12,16,24 --> first variation 


%%if var_blis == 'B3A2C0'
    % get parameters : mc, nc, kc
    [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
    Mem_L3_use] = mem_model_gap8('B3A2C0', m, n, k, MR, NR, KR);

    % model
    [PackBc, PackAc, CopyBr, StreamAc, StreamBr, StreamCr, ...
    BrmemL1, BcmemL3, AcmemL2, time_B3A2C0] = gemm_blis_B3A2C0(m, n, k, MC, NC, KC, MR, NR);
%elseif var_blis == 'B3C2A0'
    % get parameters : mc, nc, kc
    [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
    Mem_L3_use] = mem_model_gap8('B3C2A0', m, n, k, MR, NR, KR);

    %model
    [PackBc, PackCc, UnpackCc, CopyBr, StreamAr, StreamBr, StreamCr, ...
    BrmemL1, BcmemL3, CcmemL2, time_B3C2A0] = gemm_blis_B3C2A0( m, n, k, MC, NC, KC, MR, KR);

%elseif var_blis == 'C3B2A0'
    % Get parameters : mc, nc, kc
    [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
    Mem_L3_use] = mem_model_gap8('C3B2A0', m, n, k, MR, NR, KR);
        
    % model  
    [PackBc, PackCc, UnpackCc, CopyCr, StreamAr, StreamBc, StreamCc, ...
    CrmemL1, CcmemL3, BcmemL2, time_C3B2A0] = gemm_blis_C3B2A0( m, n, k, MC, NC, KC, MR, KR );
%%end
 

if visual == 1
time_all =[time_B3A2C0; time_B3C2A0; time_C3B2A0]
  
  X = categorical({'B3A2C0', 'B3C2A0', 'C3B2A0'});
  X = reordercats(X,{'B3A2C0', 'B3C2A0', 'C3B2A0'});

  time_bar = bar( X, time_all, "stacked");
  set(time_bar, {'DisplayName'}, {'PackBc', 'PackCc', 'UnpackCc', 'CopyBr/CopyCr', 'StreamA/Ac','StreamBr/Bc','StreamC/Cc/Cr', 'Arithmetic'}')
  legend()
  exportgraphics(gca, 'time_all_stacked.pdf');
end

