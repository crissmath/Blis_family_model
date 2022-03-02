function [PackBc, PackCc, UnpackCc, CopyBr, StreamAr, StreamBr, StreamCc, ...
          BrMemL1, BcMemL3, CcMemL2 ] = gemm_blis_A3B2C0( m, n, k, MC, NC, KC, MR, KR )

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
  TRPackBc   = 5.76E-01;
  TRPackCc   = 5.44E-01;
  TRUnpackCc = 6.61E-01;
  TRCopyBr   = 1.76E+01;
  TRStreamAr = 4.39E-01;
  TRStreamBr = 1.82E+02;
  TRStreamCc = 6.92E+00;
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
  PackBc    = 0;   % L3 --> L2 --> L3        (pack B to Bc)
  PackCc    = 0;   % L3 --> L2               (pack C to Cc)
  UnpackCc  = 0;   % L2 --> L3               (Unpack Cc to C)
  CopyBr    = 0;   % L3 --> L2 --> L1        (pack Bc to Br)
  StreamAr  = 0;   % L3 --> registers
  StreamBr  = 0;   % L1 --> registers
  StreamCc  = 0;   % L2 --> registers --> L2

  %% loop 1: 
  for ic=[0:MC:m-1]
    mc = min(m-ic, MC); 

    %% loop 2:
    for pc=[0:KC:k-1]
      kc = min(k-pc, KC); 
      % // pack_A( mc, nk ); % L3 --> L2 --> L3 (multiply by 2)
      PackAc = PackAc + 2 * mc * kc; 
      
      %% loop 3:
      for jc=[0:NC:n-1]
        nc = min(n-jc, NC); 
        % // pack_Bc( kc, nc ); L3 (RAM) --> L2
        PackBc  = PackBc + kc * nc; 

        %% loop 4:
        for ir=[0:MR:mc-1]
          mr = min(mc-pr, KR); 
          % // pack_B( kr, nc ) L3 --> L1
          CopyBr = CopyBr + kr * nc; 

          %% loop 5: 
          for jr=[0:NR:nc-1]
            nr = min(nc-ir, NR); 
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
  TimePackBc   =  PackBc   / (TRPackBc   * MiB);
  TimePackCc   =  PackCc   / (TRPackCc   * MiB);
  TimeUnpackCc =  UnpackCc / (TRUnpackCc * MiB);
  TimeCopyBr   =  CopyBr   / (TRCopyBr   * MiB);
  TimeStreamAr =  StreamAr / (TRStreamAr * MiB);
  TimeStreamBr =  StreamBr / (TRStreamBr * MiB);
  TimeStreamCc =  StreamCc / (TRStreamCc * MiB);

  INT8R       = 7.57E+1;
  TimeINT8Ops = INT8Ops / INT8Rate;
  Time = TimePackBc   + ...
         TimePackCc   + ...
         TimeUnpackCc + ...
         TimeCopyBr   + ...
         TimeStreamAr + ...
         TimeStreamBr + ...
         TimeStreamCc + ...
         TimeINT8Ops;
  INT8Rateactual = INT8Ops / Time;

  fprintf("---------------------------------------------------------\n")
  fprintf("m:  %4d n:  %4d k:  %4d\n", m, n, k);
  fprintf("MC: %4d NC: %4d KC: %4d\n", MC, NC, KC);
  fprintf("MR: %4d KR: %4d\n", MR, KR);
  fprintf("Datatype %s\n", DataType);
  fprintf("---------------------------------------------------------\n")
  fprintf("Component         Time            #Reads/Writes  Mbytes/s\n")
  fprintf("---------------------------------------------------------\n")
  fprintf("Pack Bc:          %6.2e        %6.2e       %6.2e\n", TimePackBc,   PackBc,   TRPackBc) 
  fprintf("Pack Cc:          %6.2e        %6.2e       %6.2e\n", TimePackCc,   PackCc,   TRPackCc) 
  fprintf("Unpack Cc:        %6.2e        %6.2e       %6.2e\n", TimeUnpackCc, UnpackCc, TRUnpackCc) 
  fprintf("Copy Br:          %6.2e        %6.2e       %6.2e\n", TimeCopyBr,   CopyBr,   TRCopyBr) 
  fprintf("Stream Ar:        %6.2e        %6.2e       %6.2e\n", TimeStreamAr, StreamAr, TRStreamAr) 
  fprintf("Stream Br:        %6.2e        %6.2e       %6.2e\n", TimeStreamBr, StreamBr, TRStreamBr) 
  fprintf("Stream Cc:        %6.2e        %6.2e       %6.2e\n", TimeStreamCc, StreamCc, TRStreamCc) 
  fprintf("\n");
  fprintf("Component         Time            #INT8 Ops    MINT8Ops/s\n")
  fprintf("---------------------------------------------------------\n")
  fprintf("Arithmetic:       %6.2e        %6.2e       %6.2e\n", TimeINT8Ops, INT8Ops, INT8Rate/Mega) 
  fprintf("\n");
  fprintf("Total:            %6.2e        %6.2e       %6.2e\n", Time, INT8Ops, INT8Rateactual/Mega) 
%
end




