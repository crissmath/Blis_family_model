function [PackBc, PackCc, UnpackCc, CopyBr, StreamAr, StreamBr, StreamCc, BrMemL1, BcMemL3, CcMemL2 ] = gemm_blis_B3C2A0( m, n, k, MC, NC, KC, MR, KR )

  % Kilobyte
  KiB  = 2^10;
  MiB  = 2^20;
  Mega = 10^6;

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
  % Experimental transfer rates
  %
  TRPackBc   = 5.76E-01 * (KR/4); % L3-->L2-->L3
  TRPackCc   = 5.44E-01 * (MR/4); % L3-->L2
  TRUnpackCc = 6.61E-01 * (MR/4); % L2-->L3
  TRCopyBr   = 1.76E+01;          % L3-->L1
  TRStreamAr = 4.39E-01;          % L3-->Reg.
  TRStreamBr = 1.82E+02;          % L1-->Reg.
  TRStreamCc = 6.92E+00;          % L2-->Reg.

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
    printf("*** Error: Br exceeds L1 capacity: %d KiB > %d KiB", BrMemL1, CapacityL1); 
    return
  end
  if (BcMemL3 > CapacityL3)
    printf("*** Error: Bc exceeds L3 capacity: %d KiB > %d KiB", BcMemL3, CapacityL3); 
    return
  end
  if (CcMemL2 > CapacityL2)
    printf("*** Error: Cc exceeds L2 capacity: %d KiB > %d KiB", CcMemL2, CapacityL2); 
    return
  end

  %
  % Calculate volume of data transfers
  %
  PackBc    = 0;    % L3 --> L2 --> L3 (pack B to Bc)
  PackCc    = 0;    % L3 --> L2        (pack C to Cc)
  UnpackCc  = 0;    % L2 --> L3        (Unpack Cc to C)
  CopyBr    = 0;    % L3 --> L1        (pack Bc to Br)
  StreamAr  = 0;   % L3 --> registers
  StreamBr  = 0;   % L1 --> registers
  StreamCc  = 0;   % L2 --> registers --> L2

  for jc=[0:NC:n-1]
    nc = min(n-jc, NC); 

    for pc=[0:KC:k-1]
      kc = min(k-pc, KC); 
      % // pack_B( kc, nc ); % L3 --> L2 --> L3 (multiply by 2)
      PackBc = PackBc + 2 * kc * nc; 

      for ic=[0:MC:m-1]
        mc = min(m-ic, MC); 
        % // pack_C( mc, nc ); L3 (RAM) --> L2
        PackCc  = PackCc + mc * nc; 

        for pr=[0:KR:kc-1]
          kr = min(kc-pr, KR); 
          % // pack_B( kr, nc ) L3 --> L1
          CopyBr = CopyBr + kr * nc; 

          for ir=[0:MR:mc-1]
            mr = min(mc-ir, MR); 

            % // gemm_base_ABresident( orderA, transA, mr, nc, kr, alpha, 
            % // Aptr, ldA, &Bc[pr*nc], KR, betaII, &Cc[ir*nc], MR );
            StreamAr = StreamAr + mr * kr; 
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

  TimePackBc   = PackBc / (TRPackBc * MiB);
  TimePackCc   = PackCc / (TRPackCc * MiB);
  TimeUnpackCc = UnpackCc / (TRUnpackCc * MiB);
  TimeCopyBr   = CopyBr / (TRCopyBr * MiB);
  TimeStreamAr   = StreamAr / (TRStreamAr * MiB);
  TimeStreamBr   = StreamBr / (TRStreamBr * MiB);
  TimeStreamCc   = StreamCc / (TRStreamCc * MiB);

  INT8R = 7.57E+1;
  INT8OPS = 2*m*n*k;
  TimeINT8OPS   = INT8Ops / INT8Rate;
  Time = TimePackBc   + ...
         TimePackCc   + ...
         TimeUnpackCc + ...
         TimeCopyBr   + ...
         TimeStreamAr + ...
         TimeStreamBr + ...
         TimeStreamCc + ...
         TimeINT8OPS;
  INT8Rateactual = INT8OPS / Time;

  printf("Component         Time            #Reads/Writes  Mbytes/s\n")
  printf("---------------------------------------------------------\n")
  printf("Pack Bc:          %6.2e        %6.2e       %6.2e\n", TimePackBc, PackBc, TRPackBc) 
  printf("Pack Cc:          %6.2e        %6.2e       %6.2e\n", TimePackCc, PackCc, TRPackCc) 
  printf("Unpack Cc:        %6.2e        %6.2e       %6.2e\n", TimeUnpackCc, UnpackCc, TRUnpackCc) 
  printf("Copy Br:          %6.2e        %6.2e       %6.2e\n", TimeCopyBr, CopyBr, TRCopyBr) 
  printf("Stream Ar:        %6.2e        %6.2e       %6.2e\n", TimeStreamAr, StreamAr, TRStreamAr) 
  printf("Stream Br:        %6.2e        %6.2e       %6.2e\n", TimeStreamBr, StreamBr, TRStreamBr) 
  printf("Stream Cc:        %6.2e        %6.2e       %6.2e\n", TimeStreamCc, StreamCc, TRStreamCc) 
  printf("\n");
  printf("Component         Time            #INT8 Ops    MINT8Ops/s\n")
  printf("---------------------------------------------------------\n")
  printf("Arithmetic:       %6.2e        %6.2e       %6.2e\n", TimeINT8OPS, INT8Ops, INT8Rate/Mega) 
  printf("\n");
  printf("Total:            %6.2e        %6.2e       %6.2e\n", Time, INT8Ops, INT8Rateactual/Mega) 
%
end
