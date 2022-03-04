function [PackBc, PackCc, UnpackCc, CopyBr, StreamA, StreamBr, StreamCc, ...
          BrMemL1, BcMemL3, CcMemL2 ] = gemm_blis_B3C2A0( m, n, k, MC, NC, KC, MR, KR )

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
  TRPackBc   = L3toL2toL3 * (KR/4); % L3 --> L2 --> L3
  TRPackCc   = L3toL2     * (MR/4); % L3 --> L2
  TRUnpackCc = L2toL3     * (MR/4); % L2 --> L3
  TRCopyBr   = L3toL1;              % L3 --> L1
  TRStreamA = L3toReg;             % L3 --> Reg.
  TRStreamBr = L1toReg;             % L1 --> Reg.
  TRStreamCc = L2toReg;             % L2 --> Reg.

  %
  % Experimental INT8 Ops/s 
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
  BrMemL1   = KR * NC / KiB;
  BcMemL3   = KC * NC / KiB;
  CcMemL2   = MC * NC / KiB;

  %
  % Check memory capacity
  %
  if (BrMemL1 > CapacityL1)
    fprintf("*** Error: Br exceeds L1 capacity: %d KiB > %d KiB", BrMemL1, CapacityL1); 
    return
  end
  if (BcMemL3 > CapacityL3)
    fprintf("*** Error: Bc exceeds L3 capacity: %d KiB > %d KiB", BcMemL3, CapacityL3); 
    return
  end
  if (CcMemL2 > CapacityL2)
    fprintf("*** Error: Cc exceeds L2 capacity: %d KiB > %d KiB", CcMemL2, CapacityL2); 
    return
  end

  %
  % Calculate volume of data transfers
  %
  PackBc    = 0;    % L3 --> L2 --> L3 (pack B to Bc)
  PackCc    = 0;    % L3 --> L2        (pack C to Cc)
  UnpackCc  = 0;    % L2 --> L3        (Unpack Cc to C)
  CopyBr    = 0;    % L3 --> L1        (pack Bc to Br)
  StreamA  = 0;   % L3 --> registers
  StreamBr  = 0;   % L1 --> registers
  StreamCc  = 0;   % L2 --> registers --> L2

  %% loop 1: jc
  for jc=[0:NC:n-1]
    nc = min(n-jc, NC); 

    %% loop 2: pc
    for pc=[0:KC:k-1]
      kc = min(k-pc, KC); 
      % // pack_B( kc, nc ); % L3 --> L2 --> L3 (multiply by 2)
      PackBc = PackBc + 2 * kc * nc; 

      %% loop 3: ic
      for ic=[0:MC:m-1]
        mc = min(m-ic, MC); 
        % // pack_C( mc, nc ); L3 (RAM) --> L2
        PackCc  = PackCc + mc * nc; 

        %% loop 4: pr
        for pr=[0:KR:kc-1]
          kr = min(kc-pr, KR); 
          % // Copy_Br( kr, nc ) L3 --> L1
          CopyBr = CopyBr + kr * nc; 

          %% loop 5: ir
          for ir=[0:MR:mc-1]
            mr = min(mc-ir, MR); 

            % // gemm_base_ABresident( orderA, transA, mr, nc, kr, alpha, 
            % // Aptr, ldA, &Bc[pr*nc], KR, betaII, &Cc[ir*nc], MR );
            StreamA = StreamA + mr * kr; 
            StreamBr = StreamBr + kr * nc;
            StreamCc = StreamCc + 2 * mr * nc; % L2 --> registers --> L2 (multiply by 2)
          end
        end
        % // unpack_C( mc, nc ); L2 --> L3 (RAM) 
        UnpackCc  = UnpackCc + mc * nc; 
      end
    end
  end



  % -------------------------------------------------------------------------------------------
  % Estimate execution time
  % -------------------------------------------------------------------------------------------
  TimePackBc     = DataSize * PackBc / (TRPackBc * MiB);
  TimePackCc     = DataSize * PackCc / (TRPackCc * MiB);
  TimeUnpackCc   = DataSize * UnpackCc / (TRUnpackCc * MiB);
  TimeCopyBr     = DataSize * CopyBr / (TRCopyBr * MiB);
  TimeStreamA   = DataSize * StreamA / (TRStreamA * MiB);
  TimeStreamBr   = DataSize * StreamBr / (TRStreamBr * MiB);
  TimeStreamCc   = DataSize * StreamCc / (TRStreamCc * MiB);

  INT8R = 7.57E+1;
  INT8OPS = 2*m*n*k;
  TimeINT8OPS   = INT8Ops / INT8Rate;
  Time = TimePackBc   + ...
         TimePackCc   + ...
         TimeUnpackCc + ...
         TimeCopyBr   + ...
         TimeStreamA + ...
         TimeStreamBr + ...
         TimeStreamCc + ...
         TimeINT8OPS;
  INT8Rateactual = INT8OPS / Time;

  fprintf("Component         Time            #Reads/Writes  Mbytes/s\n")
  fprintf("---------------------------------------------------------\n")
  fprintf("Pack Bc:          %6.2e        %6.2e       %6.2e\n", TimePackBc, PackBc, TRPackBc) 
  fprintf("Pack Cc:          %6.2e        %6.2e       %6.2e\n", TimePackCc, PackCc, TRPackCc) 
  fprintf("Unpack Cc:        %6.2e        %6.2e       %6.2e\n", TimeUnpackCc, UnpackCc, TRUnpackCc) 
  fprintf("Copy Br:          %6.2e        %6.2e       %6.2e\n", TimeCopyBr, CopyBr, TRCopyBr) 
  fprintf("Stream A :        %6.2e        %6.2e       %6.2e\n", TimeStreamA, StreamA, TRStreamA) 
  fprintf("Stream Br:        %6.2e        %6.2e       %6.2e\n", TimeStreamBr, StreamBr, TRStreamBr) 
  fprintf("Stream Cc:        %6.2e        %6.2e       %6.2e\n", TimeStreamCc, StreamCc, TRStreamCc) 
  fprintf("\n");
  fprintf("Component         Time            #INT8 Ops    MINT8Ops/s\n")
  fprintf("---------------------------------------------------------\n")
  fprintf("Arithmetic:       %6.2e        %6.2e       %6.2e\n", TimeINT8OPS, INT8Ops, INT8Rate/Mega) 
  fprintf("\n");
  fprintf("Total:            %6.2e        %6.2e       %6.2e\n", Time, INT8Ops, INT8Rateactual/Mega) 
%
end
