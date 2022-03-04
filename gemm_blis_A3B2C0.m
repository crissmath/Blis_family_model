function [PackBc, PackAc, UnpackAc, CopyAr, StreamAr, StreamBc, StreamCr, ...
          ArMemL1, AcMemL3, BcMemL2 ] = gemm_blis_A3B2C0( m, n, k, MC, NC, KC, MR, KR, NR )

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
  TRPackBc   = L3toL2     * (KR/4);   % L3 --> L2
  TRPackAc   = L3toL2toL3 * (MR/4);   % L3 --> L2 --> L3
  TRUnpackAc = L3toL2toL3 * (MR/4);   % L3 --> L2 --> L3
  TRCopyAr   = L3toL1;                % L3 --> L1         
  TRStreamAr = L1toReg;               % L1 --> Reg        (Load Ar)
  TRStreamBc = L2toReg;               % L1 --> Reg        (Load Bc)
  TRStreamCr = L3toReg;               % L2 --> Reg        (Load && write Cc)
  %
  % Experimental Ops/s (in INT8 MOps/s)
  %
  INT8Rate = 8.40E+1 * Mega;

  % -------------------------------------------------------------------------------------------
  % Algorithm B3C2A0 parameters
  % -------------------------------------------------------------------------------------------

  %
  % Number of arithmetic operations
  %
  INT8Ops = 2*m*n*k;

  %
  % Size of buffers
  %
  ArMemL1   = MR * KC / KiB;
  BcMemL2   = KC * NC / KiB;
  AcMemL3   = MC * KC / KiB;

  %
  % Check memory capacity
  %
  if (ArMemL1 > CapacityL1)
    fprintf("*** Error: Ar exceeds L1 capacity: %d KiB > %d KiB", ArMemL1, CapacityL1); 
    return
  end
  if (BcMemL2 > CapacityL2)
    fprintf("*** Error: Bc exceeds L2 capacity: %d KiB > %d KiB", BcMemL2, CapacityL2); 
    return
  end
  if (AcMemL3 > CapacityL3)
    fprintf("*** Error: Ac exceeds L3 capacity: %d KiB > %d KiB", AcMemL2, CapacityL3); 
    return
  end

  %
  % Calculate volume of data transfers
  %
  PackAc    = 0;   % L3 --> L2 --> L3        
  PackBc    = 0;   % L3 --> L2               
  UnpackAc  = 0;   % L3 --> L2 --> L3               
  CopyAr    = 0;   % L3 --> L1
                   % L1 --> L3        
  StreamAr  = 0;   % L1 --> registers
  StreamBc  = 0;   % L2 --> registers
  StreamCr  = 0;   % L3 --> registers 

  %% loop 1: ic
  for ic=[0:MC:m-1]
    mc = min(m-ic, MC); 

    %% loop 2: pc
    for pc=[0:KC:k-1]
      kc = min(k-pc, KC); 
      % // pack_A( mc, nk ); % L3 --> L2 --> L3 (multiply by 2)
      PackAc = PackAc + 2 * mc * kc; 
      
      %% loop 3: jc
      for jc=[0:NC:n-1]
        nc = min(n-jc, NC); 
        % // pack_Bc( kc, nc ); L3 (RAM) --> L2
        PackBc  = PackBc + kc * nc; 

        %% loop 4: ir
        for ir=[0:MR:mc-1]
          mr = min(mc-ir, MR); 
          % // pack_A( mr, kc ) L3 --> L1
          CopyAr = CopyAr + mr * kc; 

          %% loop 5: jr
          for jr=[0:NR:nc-1]
            nr = min(nc-jr, NR); 
            % // gemm_base_ABresident( orderA, transA, mr, nc, kr, alpha, 
            % // Aptr, ldA, &Bc[pr*nc], KR, betaII, &Cc[ir*nc], MR );
            StreamAr = StreamAr + mr * kc; 
            StreamBc = StreamBc + kc * nr;
            StreamCr = StreamCr + 2 * mr * nr; % L2 --> registers --> L2 (multiply by 2)
          end
          %%Copy back Ar L1 --> L3
          CopyAr = CopyAr + mr * kc;
        end
        % // unpack_A( mc, kc ); L2 --> L3 (RAM) 
        UnpackAc  = UnpackAc + mc * kc; 
      end
    end
  end

  % -------------------------------------------------------------------------------------------
  % Estimate execution time
  % -------------------------------------------------------------------------------------------
  TimePackBc   =  DataSize * PackBc   / (TRPackBc   * MiB);
  TimePackAc   =  DataSize * PackAc   / (TRPackAc   * MiB);
  TimeUnpackAc =  DataSize * UnpackAc / (TRUnpackAc * MiB);
  TimeCopyAr   =  DataSize * CopyAr   / (TRCopyAr   * MiB);
  TimeStreamAr =  DataSize * StreamAr / (TRStreamAr * MiB);
  TimeStreamBc =  DataSize * StreamBc / (TRStreamBc * MiB);
  TimeStreamCr =  DataSize * StreamCr / (TRStreamCr * MiB);

  INT8R       = 7.57E+1;
  TimeINT8Ops = INT8Ops / INT8Rate;
  Time = TimePackBc   + ...
         TimePackAc   + ...
         TimeUnpackAc + ...
         TimeCopyAr   + ...
         TimeStreamAr + ...
         TimeStreamBc + ...
         TimeStreamCr + ...
         TimeINT8Ops;
  INT8Rateactual = INT8Ops / Time;

  fprintf("---------------------------------------------------------\n")
  fprintf("Component         Time            #Reads/Writes  Mbytes/s\n")
  fprintf("---------------------------------------------------------\n")
  fprintf("Pack Bc:          %6.2e        %6.2e       %6.2e\n", TimePackBc,   PackBc,   TRPackBc) 
  fprintf("Pack Ac:          %6.2e        %6.2e       %6.2e\n", TimePackAc,   PackAc,   TRPackAc) 
  fprintf("Unpack Ac:        %6.2e        %6.2e       %6.2e\n", TimeUnpackAc, UnpackAc, TRUnpackAc) 
  fprintf("Copy Ar:          %6.2e        %6.2e       %6.2e\n", TimeCopyAr,   CopyAr,   TRCopyAr) 
  fprintf("Stream Ar:        %6.2e        %6.2e       %6.2e\n", TimeStreamAr, StreamAr, TRStreamAr) 
  fprintf("Stream Br:        %6.2e        %6.2e       %6.2e\n", TimeStreamBc, StreamBc, TRStreamBc) 
  fprintf("Stream Cc:        %6.2e        %6.2e       %6.2e\n", TimeStreamCr, StreamCr, TRStreamCr) 
  fprintf("\n");
  fprintf("Component         Time            #INT8 Ops    MINT8Ops/s\n")
  fprintf("---------------------------------------------------------\n")
  fprintf("Arithmetic:       %6.2e        %6.2e       %6.2e\n", TimeINT8Ops, INT8Ops, INT8Rate/Mega) 
  fprintf("\n");
  fprintf("Total:            %6.2e        %6.2e       %6.2e\n", Time, INT8Ops, INT8Rateactual/Mega) 
%
end




