function [PackBc, PackCc, UnpackCc, CopyCr, StreamA, StreamBc, StreamCr, ....
          CrMemL1, CcMemL3, BcMemL2 ] = gemm_blis_C3B2A0( m, n, k, MC, NC, KC, MR, KR )

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
  TRPackBc   = L3toL2     * (KR/4);  % L3 --> L2
  TRPackCc   = L3toL2toL3 * (MR/4);  % L3 --> L2 --> L3
  TRUnpackCc = L3toL2toL3 * (MR/4);  % L3 --> L2 --> L3
  TRCopyCr   = L3toL1;               % L3 --> L1
  TRStreamA = L3toReg;              % L3 --> Reg.
  TRStreamBc = L2toReg;              % L2 --> Reg.
  TRStreamCr = L1toReg;              % L1 --> Reg.

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
  CrMemL1   = MR * NC / KiB;
  BcMemL2   = KC * NC / KiB;
  CcMemL3   = MC * NC / KiB;

  %
  % Check memory capacity
  %
  if (CrMemL1 > CapacityL1)
    fprintf("*** Error: Cr exceeds L1 capacity: %d KiB > %d KiB", CrMemL1, CapacityL1); 
    return
  end
  if (BcMemL2 > CapacityL2)
    fprintf("*** Error: Bc exceeds L2 capacity: %d KiB > %d KiB", BcMemL2, CapacityL2); 
    return
  end
  if (CcMemL3 > CapacityL3)
    fprintf("*** Error: Cc exceeds L3 capacity: %d KiB > %d KiB", CcMemL3, CapacityL3); 
    return
  end

  %
  % Calculate volume of data transfers
  %
  PackCc    = 0;   % L3 --> L2 --> L3        (pack C to Cc)
  PackBc    = 0;   % L3 --> L2               (pack B to Bc)
  UnpackCc  = 0;   % L3 --> L2 --> L3        (Unpack Cc to C)
  CopyCr    = 0;   % L3 --> L1               (pack Cc to Cr, and
                   % L1 --> L3                unpack Cr to Cc)
  StreamA  = 0;   % L3 --> registers
  StreamBc  = 0;   % L2 --> registers
  StreamCr  = 0;   % L1 --> registers --> L1

  %% loop 1: jc
  for jc=[0:NC:n-1]
    nc = min(n-jc, NC); 

    %% loop 2: ic
    for ic=[0:MC:m-1]
      mc = min(m-ic, MC); 
      % // pack_C( mc, nc ); % L3 --> L2 --> L3 (multiply by 2)
      PackCc = PackCc + 2 * mc * nc; 
      
      %% loop 3: pc
      for pc=[0:KC:k-1]
        kc = min(k-pc, KC); 
        % // pack_B( kc, nc ); L3 (RAM) --> L2
        PackBc  = PackBc + kc * nc; 

        %% loop 4: ir
        for ir=[0:MR:mc-1]
          mr = min(mc-ir, MR); 
          % // Copy_C( mr, nc ) L3 --> L1
          CopyCr = CopyCr + mr * nc; 

          %% loop 5: pr
          for pr=[0:KR:kc-1]
            kr = min(kc-pr, KR); 
            % // gemm_base_ABresident( orderA, transA, mr, nc, kr, alpha, 
            % // Aptr, ldA, &Bc[pr*nc], KR, betaII, &Cc[ir*nc], MR );
            StreamA = StreamA + mr * kr; 
            StreamBc = StreamBc + kr * nc;
            StreamCr = StreamCr + 2 * mr * nc; % L1 --> registers --> L1 (multiply by 2)
          end
          %% Copy back Cr L1 --> L3
          CopyCr = CopyCr + mr * nc; 
        end
      end
      % // unpack_C( mc, nc ); L3 --> L2 --> L3 (RAM) 
      UnpackCc  = UnpackCc + 2 * mc * nc; 
    end
  end

  % -------------------------------------------------------------------------------------------
  % Estimate execution time :
  % -------------------------------------------------------------------------------------------
  TimePackBc   = DataSize * PackBc   / (TRPackBc * MiB);
  TimePackCc   = DataSize * PackCc   / (TRPackCc * MiB);
  TimeUnpackCc = DataSize * UnpackCc / (TRUnpackCc * MiB);
  TimeCopyCr   = DataSize * CopyCr   / (TRCopyCr * MiB);
  TimeStreamA = DataSize * StreamA / (TRStreamA * MiB);
  TimeStreamBc = DataSize * StreamBc / (TRStreamBc * MiB);
  TimeStreamCr = DataSize * StreamCr / (TRStreamCr * MiB);

  INT8R     = 7.57E+1;
  TimeINT8Ops   = INT8Ops / INT8Rate;
  Time = TimePackBc   + ...
         TimePackCc   + ...
         TimeUnpackCc + ...
         TimeCopyCr   + ...
         TimeStreamA + ...
         TimeStreamBc + ...
         TimeStreamCr + ...
         TimeINT8Ops;
  INT8Rateactual = INT8Ops / Time;

  fprintf("---------------------------------------------------------\n")
  fprintf("Component         Time            #Reads/Writes  Mbytes/s\n")
  fprintf("---------------------------------------------------------\n")
  fprintf("Pack Bc:          %6.2e        %6.2e       %6.2e\n", TimePackBc,   PackBc,   TRPackBc) 
  fprintf("Pack Cc:          %6.2e        %6.2e       %6.2e\n", TimePackCc,   PackCc,   TRPackCc) 
  fprintf("Unpack Cc:        %6.2e        %6.2e       %6.2e\n", TimeUnpackCc, UnpackCc, TRUnpackCc) 
  fprintf("Copy Cr:          %6.2e        %6.2e       %6.2e\n", TimeCopyCr,   CopyCr,   TRCopyCr) 
  fprintf("Stream A :        %6.2e        %6.2e       %6.2e\n", TimeStreamA, StreamA, TRStreamA) 
  fprintf("Stream Bc:        %6.2e        %6.2e       %6.2e\n", TimeStreamBc, StreamBc, TRStreamBc) 
  fprintf("Stream Cr:        %6.2e        %6.2e       %6.2e\n", TimeStreamCr, StreamCr, TRStreamCr) 
  fprintf("\n");
  fprintf("Component         Time            #INT8 Ops    MINT8Ops/s\n")
  fprintf("---------------------------------------------------------\n")
  fprintf("Arithmetic:       %6.2e        %6.2e       %6.2e\n", TimeINT8Ops, INT8Ops, INT8Rate/Mega) 
  fprintf("\n");
  fprintf("Total:            %6.2e        %6.2e       %6.2e\n", Time, INT8Ops, INT8Rateactual/Mega) 
%
end
