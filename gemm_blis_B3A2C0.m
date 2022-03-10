function [PackBc, PackAc, CopyBr, StreamAc, StreamBr, StreamC, ...
BrMemL1, BcMemL3, AcMemL2, B3A2C0_time] = gemm_blis_B3A2C0( m, n, k, MC, NC, KC, MR,NR)

  % Kilobyte
  KiB  = 2^10;
  MiB  = 2^20;
  Mega = 10^6;

  % DataSize. INT8 = 1 byte
  DataSize = 1;
  DataType = 'INT8';
  % -------------------------------------------------------------------------------------------
  % Architecture parameters
  % -------------------------------------------------------------------------------------------

  %
  % Capacity of cache memories
  %
  CapacityL1 =  16*KiB;
  CapacityL2 = 512*KiB;
  CapacityL3 = inf*KiB;

  %
  % Experimental transfer rates (in MBytes/s)
  %
  L1toReg    = 1.82E+02;
  L2toReg    = 6.92E+00;
  L3toReg    = 4.39E-01;
  L3toL2toL3 = 5.76E-01;
  L3toL1     = 1.76E+01;
  L3toL2     = 5.44E-01;
  L2toL3     = 6.61E-01;
 
  %
  TRPackBc   = L3toL2toL3 * (NR/4);   % L3 --> L2 --> L3
  TRPackAc   = L3toL2     * (MR/4);  
  TRCopyBr   = L3toL1;                % L3 --> L1         
  TRStreamAc = L2toReg;               % L2 --> Reg        (Load Ar)
  TRStreamBr = L1toReg;               % L1 --> Reg        (Load Bc)
  TRStreamC = L3toReg;               % L2 --> Reg        (Load && write Cc)
  %
  % Experimental Ops/s (in INT8 MOps/s)
  %
  INT8Rate = 8.40E+1 * Mega;

  % -------------------------------------------------------------------------------------------
  % Algorithm B3A2C0 parameters
  % -------------------------------------------------------------------------------------------

  %
  % Number of arithmetic operations
  %
  INT8Ops = 2*m*n*k;

  %
  % Size of buffers
  %
  BcMemL3   = KC * NC / KiB;
  BrMemL1   = KC * NR / KiB;
  AcMemL2   = MC * KC / KiB;

  %
  % Check memory capacity
  %
  if (BrMemL1 > CapacityL1)
    fprintf("*** Error: Br exceeds L1 capacity: %d KiB > %d KiB", BrMemL1, CapacityL1); 
    return
  end
  if (AcMemL2 > CapacityL2)
    fprintf("*** Error: Ac exceeds L2 capacity: %d KiB > %d KiB", AcMemL2, CapacityL2); 
    return
  end
  if (BcMemL3 > CapacityL3)
    fprintf("*** Error: Bc exceeds L3 capacity: %d KiB > %d KiB", BcMemL2, CapacityL3); 
    return
  end

  %
  % Calculate volume of data transfers
  %
  PackBc    = 0;   % L3 --> L2 --> L3        
  PackAc    = 0;   % L3 --> L2               
  CopyBr    = 0;   % L3 --> L1
                   % L1 --> L3        
  StreamAc  = 0;   % L2 --> registers
  StreamBr  = 0;   % L1 --> registers
  StreamC  = 0;   % L3 --> registers 

  %% loop 1: jc
for jc=[0:NC:n-1]
  nc = min(n-jc, NC);

    %% loop 2: pc
    for pc=[0:KC:k-1]
      kc = min(k-pc, KC); 
      % // pack_A( mc, nk ); % L3 --> L2 --> L3 (multiply by 2)
      PackBc = PackBc + 2 * kc * nc; 
     
      %% loop 3: ic
      for ic=[0:MC:m-1]
          mc = min(m-ic, MC); 
        % // pack_Bc( kc, nc ); L3 (RAM) --> L2
        PackAc  = PackAc + mc * kc; 

      %% loop 4: jr
        for jr=[0:NR:nc-1]
            nr = min(nc-jr, NR); 
            % // Copy_B( kc, nr ) L3 --> L1
            CopyBr = CopyBr + kc * nr; 

         %% loop 5: ir
          for ir=[0:MR:mc-1]
            mr = min(mc-ir, MR); 
            % // gemm_base_ABresident( orderA, transA, mr, nc, kr, alpha, 
            % // Aptr, ldA, &Bc[pr*nc], KR, betaII, &Cc[ir*nc], MR );
            StreamAc = StreamAc + mr * kc; 
            StreamBr = StreamBr + kc * nr;
            StreamC = StreamC + 2 * mr * nr; % L2 --> registers --> L2 (multiply by 2)
          end
        end
      end
    end
  end

  % -------------------------------------------------------------------------------------------
  % Estimate execution time
  % -------------------------------------------------------------------------------------------
  TimePackBc   =  DataSize * PackBc   / (TRPackBc   * MiB);
  TimePackAc   =  DataSize * PackAc   / (TRPackAc   * MiB);
  TimeCopyBr   =  DataSize * CopyBr   / (TRCopyBr   * MiB);
  TimeStreamAc =  DataSize * StreamAc / (TRStreamAc * MiB);
  TimeStreamBr =  DataSize * StreamBr / (TRStreamBr * MiB);
  TimeStreamC  =  DataSize * StreamC / (TRStreamC * MiB);

  INT8R       = 7.57E+1;
  TimeINT8Ops = INT8Ops / INT8Rate;
  Time = TimePackBc   + ...
         TimePackAc   + ...
         TimeCopyBr   + ...
         TimeStreamAc + ...
         TimeStreamBr + ...
         TimeStreamC + ...
         TimeINT8Ops;
  INT8Rateactual = INT8Ops / Time;

  fprintf("---------------------------------------------------------\n")
  fprintf("Component         Time            #Reads/Writes  Mbytes/s\n")
  fprintf("---------------------------------------------------------\n")
  fprintf("Pack Bc:          %6.2e        %6.2e       %6.2e\n", TimePackBc,   PackBc,   TRPackBc) 
  fprintf("Pack Ac:          %6.2e        %6.2e       %6.2e\n", TimePackAc,   PackAc,   TRPackAc) 
  fprintf("Copy Br:          %6.2e        %6.2e       %6.2e\n", TimeCopyBr,   CopyBr,   TRCopyBr) 
  fprintf("Stream Ac:        %6.2e        %6.2e       %6.2e\n", TimeStreamAc, StreamAc, TRStreamAc) 
  fprintf("Stream Br:        %6.2e        %6.2e       %6.2e\n", TimeStreamBr, StreamBr, TRStreamBr) 
  fprintf("Stream C :        %6.2e        %6.2e       %6.2e\n", TimeStreamC, StreamC, TRStreamC) 
  fprintf("\n");
  fprintf("Component         Time            #INT8 Ops    MINT8Ops/s\n")
  fprintf("---------------------------------------------------------\n")
  fprintf("Arithmetic:       %6.2e        %6.2e       %6.2e\n", TimeINT8Ops, INT8Ops, INT8Rate/Mega) 
  fprintf("\n");
  fprintf("Total:            %6.2e        %6.2e       %6.2e\n", Time, INT8Ops, INT8Rateactual/Mega)

  %X = categorical({'Pack Bc', 'Pack Ac', 'Copy Br', 'Stream Ac', 'Stream Br', 'Stream C'}); 
  %X = categorical({'B3A2C0'});
  B3A2C0_time = [TimePackBc, TimePackAc, TimeCopyBr, TimeStreamAc, ...
                 TimeStreamBr, TimeStreamAc, 0, TimeINT8Ops];

  % time_bar = bar( X, B3A2C0_time, 'stacked');
  % exportgraphics(gca, 'B3A2C0_t.pdf');
%
end




