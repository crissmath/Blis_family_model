function [MC, NC, KC, Mem_L1, Mem_L2, Mem_L3, Mem_L1_use, Mem_L2_use, ...
     Mem_L3_use] = mem_model_gap8(variant, m, n, k, MR, NR, KR)

%variant = 'C3B2A0'; %'B3A2C0' ; %'B3C2A0';
%m = 1792; 
%n = 1536;
%k = 1024;
%MR = 4;
%NR = 4;
%KR = 4;

% Data size 
KiB = 2^10;
MiB = 2^20;
%
% Total Memory capacity
Mem_L1 = 16*KiB;
Mem_L2 = 512*KiB;
Mem_L3 = 8*MiB;

if variant == 'B3A2C0'
    % L3
    A_L3  = m * k;
    B_L3  = k * n;
    C_L3  = m * n;
    %
    % L2
    Ag_L2  = m * n;
    %
    % L2+test
    A_2_L2 = m * n;
    Ag     = m * k;
    Bg     = k * n;
    %--------------------------------
    %   Memory use include buffers
    %--------------------------------
    Mem_L3_use = A_L3 + B_L3 + C_L3;
    if(Mem_L3_use > Mem_L3)
        fprintf("Use of L3 us exeded..\n");
    else 
        Mem_L3 = Mem_L3 - Mem_L3_use;
    end
    %================================================
    %       B3A2C0: mc, nc, kc
    %================================================
    % Br --> L1(KC*NR) --> KC = L1/NR
    KC = 4 * floor((Mem_L1 / NR) / 4);
    % Ac --> L2(MC*KC)
    MC = 4 * floor((Mem_L2 / min(k,KC)) / 4);
    % Bc --> L3(KC*NC)
    NC = 4 * floor((Mem_L3 / min(k,KC)) / 4);
    %================================================
    % Check space in memory
    % Buffer for data 
    % L3 
    Bc_L3 = KC * NC;
    % L2
    Brtmp_L2 = KR * NC;
    Artmp_L2 = MR * KR;
    % L1
    Br_L1 = KR * NC;
    %
    % Memory use include buffer
    Mem_L1_use = Br_L1;
    Mem_L2_use = A_2_L2;
    L2_use = Artmp_L2 + Brtmp_L2; % add L2+test 
    %L1 = L1-Mem_L1_use;
    %L2 = L2-L2_use;

elseif variant == 'B3C2A0'
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
    Mem_L3_use = A_L3 + B_L3 + C_L3;
    if(Mem_L3_use > Mem_L3)
        fprintf("Use of L3 us exeded..\n");
    else 
        Mem_L3 = Mem_L3-Mem_L3_use;
    end
    %================================================
    % Calculate mc, nc, kc
    %================================================
    % Br --> L1(KR*NC)
    % NC = L1/KR
    NC = 4*floor((Mem_L1/KR)/4);
    % Cc --> L2(MC*NC) 
    MC = 4*floor((Mem_L2/min(n,NC))/4); % if NC>n  
    % Bc --> L3(KC*NC)
    KC = 4*floor((Mem_L3/min(n,NC))/4);
    %================================================
    % Check space in memory
    % Buffer for data 
    % L3 
    Bc_L3 = KC * NC;
    % L2
    Brtmp_L2 = KR * NC;
    Artmp_L2 = MR * KR;
    % L1
    Br_L1 = KR * NC;
    %
    % Memory use include buffer
    Mem_L1_use = Br_L1;
    Mem_L2_use = Cg_L2; % add L2+test: 
    Mem_L1 = Mem_L1 - Mem_L1_use;
    Mem_L2 = Mem_L2 - Mem_L2_use;
    
elseif variant == 'C3B2A0'
    % L3
    A_L3  = m * k;
    B_L3  = k * n;
    C_L3  = m * n;
    %
    % L2
    Bg_L2  = m * n;
    %
    % L2+test
    B_2_L2 = m * n;
    Ag     = m * k;
    Bg     = k * n;
    %--------------------------------
    %   Memory use include buffers
    %--------------------------------
    Mem_L3_use = A_L3 + B_L3 + C_L3;
    if(Mem_L3_use > Mem_L3)
        fprintf(" Exceeds L3 capacity : %d Kib > %d KiB\n",L3_use, Mem_L3);
    else 
        Mem_L3 = Mem_L3 - Mem_L3_use;
    end
    %================================================
    %       C3B2A0 : mc, nc, kc
    %================================================
    % Cr --> L1(MR*NC) --> NC = L1/MR
    NC = 4 * floor((Mem_L1 / MR) / 4);
    % Bc --> L2(KC*NC)
    KC = 4 * floor((Mem_L2 / min(n,NC)) / 4);
    % Cc --> L3(MC*NC)
    MC = 4 * floor((Mem_L3 / min(n,NC)) / 4);
    %================================================
    % Check space in memory
    % Buffer for data 
    % L3 
    Bc_L3 = KC * NC;
    % L2
    Brtmp_L2 = KR * NC; % dont include temporal buffers
    Artmp_L2 = MR * KR;
    % L1
    Cr_L1 = KR * NC;
    %
    % Memory use include buffer
    Mem_L1_use = Cr_L1;
    Mem_L2_use = B_2_L2;
    Mem_L1 = Mem_L1 - Mem_L1_use;
    Mem_L2 = Mem_L2 - Mem_L2_use;
%
end

fprintf("------------------------------------------------\n");
fprintf("variant : %s \n", variant);
fprintf("------------------------------------------------\n");
fprintf("mc = %d, nc = %d, kc = %d\n", MC, NC, KC);
fprintf("------------------------------------------------\n");
fprintf("Memory         L1          L2          L3\n");
fprintf("------------------------------------------------\n");
fprintf("Used:          %3.2e       %6.2e       %6.2e\n", Mem_L1_use, Mem_L2_use, Mem_L3_use);
fprintf("Free:          %3.2e       %6.2e       %6.2e\n", Mem_L1, Mem_L2, Mem_L3);

%
end