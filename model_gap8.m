clear all

m = 1792; 
n = 1536;
k = 1024;

MR = 4;
NR = 4;
KR = 4;
% Data size 
KiB = 2^10;
MiB = 2^20;
%
% Total Memory capacity
L1 = 16*KiB;
L2 = 512*KiB;
L3 = 8*MiB;


if variant == 'B3C2A0'
    % L3
    A_L3  = m*k;
    B_L3  = k*n;
    C_L3  = m*n;
    %
    % L2
    Cg_L2  = m*n;
    %
    % L2+test
    C_2_L2 = m*n;
    Ag     = m*k;
    Bg     = k*n;
    %
    % Memory use include buffers
    %L3_use = A_L3 + B_L3 + C_L3;
    %if(L3_use > L3)
    %    fprintf("Use of L3 us exeded..\n");
    %else 
    %    L3 = L3-L3_use;
    %end
    %================================================
    % Calculate mc, nc, kc
    %================================================
    % Br --> L1(KR*NC)
    % NC = L1/KR
    NC = L1/KR;
    % Cc --> L2(MC*NC)
    MC = L2/NC;
    % Bc --> L3(KC*NC)
    KC = L3/NC;
    %================================================
    % Check space in memory
    % Buffer for data 
    % L3 
    Bc_L3 = KC*NC;
    % L2
    Brtmp_L2 = KR*NC;
    Artmp_L2 = MR*KR;
    % L1
    Br_L1 = KR*NC;
    %
    % Memory use include buffer
    L1_use = Br_L1;
    L2_use = Artmp_L2 + Brtmp_L2 + Cg_L2; % add L2+test 
    %L1 = L1-L1_use;
    %L2 = L2-L2_use;

elseif variant == 'B3A2C0'
    % L3
    A_L3  = m*k;
    B_L3  = k*n;
    C_L3  = m*n;
    %
    % L2
    Ag_L2  = m*n;
    %
    % L2+test
    A_2_L2 = m*n;
    Ag     = m*k;
    Bg     = k*n;
    %
    % Memory use include buffers
    %L3_use = A_L3 + B_L3 + C_L3;
    %if(L3_use > L3)
    %    fprintf("Use of L3 us exeded..\n");
    %else 
    %    L3 = L3-L3_use;
    %end
    %================================================
    %       Calculate mc, nc, kc
    %================================================
    % Br --> L1(KC*NR) --> NC = L1/KR
    NC = L1/KR;
    % Cc --> L2(MC*NC)
    MC = L2/NC;
    % Bc --> L3(KC*NC)
    KC = L3/NC;
    %================================================
    % Check space in memory
    % Buffer for data 
    % L3 
    Bc_L3 = KC*NC;
    % L2
    Brtmp_L2 = KR*NC;
    Artmp_L2 = MR*KR;
    % L1
    Br_L1 = KR*NC;
    %
    % Memory use include buffer
    L1_use = Br_L1;
    L2_use = Artmp_L2 + Brtmp_L2 + Cg_L2; % add L2+test 
    %L1 = L1-L1_use;
    %L2 = L2-L2_use;
%
end
fprintf("*** B3C2A0 ***\n");
fprintf("GAP8 , INT8: \n");
fprintf("---------------------------------------------------------------\n");
fprintf("kc = %d, mc = %d, nc = %d\n", KC, MC, NC);
fprintf("---------------------------------------------------------------\n");
fprintf("Memory use\n")
fprintf("----------------------------------------------------------------\n");
fprintf("L1             L2                  L3\n");
fprintf("%3.2e      %6.2e           %6.2e\n", L1, L2, L3);
















