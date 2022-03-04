%
%     SLx:    Size of cache level (in Kbytes)
%     NLx:    Number of sets
%     CLx:    Bytes per line
%     WLx:    Associativity degree
%     Sdata:  Bytes per element (e.g., 8 for FP64)
%

% ----------------------------------------------------------------------------
% Intel Dunnington, FP64
fprintf("----------------------------------------------------------------------\n")
clear
mr=4; nr=4;
Sdata=8;

SL1=32; WL1=8; NL1 = 64; CL1 = SL1 / (WL1 * NL1);
kc = model_level(SL1, NL1, CL1, WL1, Sdata, mr, nr);

SL2=3072; WL2=12; NL2 = 4096; CL2 = SL2 / (WL2 * NL2);
mc = model_level(SL2, NL2, CL2, WL2, Sdata, kc, nr);
fprintf("Intel Dunnington, FP64:  kc = %d, mc = %d\n", kc, mc);
fprintf("The results for this processor do not match those in the paper 'Analytical modeling is enough...'\n");
fprintf("This is most likely an error in the paper\n");

% ----------------------------------------------------------------------------
% Intel Sandy Bridge, FP64
fprintf("----------------------------------------------------------------------\n")
clear
mr=8; nr=4;
Sdata=8;

SL1=32; WL1=8; NL1 = 64; CL1 = SL1 / (WL1 * NL1);
kc = model_level(SL1, NL1, CL1, WL1, Sdata, mr, nr);

SL2=256; WL2=8; NL2 = 512; CL2 = SL2 / (WL2 * NL2);
mc = model_level(SL2, NL2, CL2, WL2, Sdata, kc, nr);
fprintf("Intel SandyBridge, FP64: kc = %d, mc = %d\n", kc, mc);

% ----------------------------------------------------------------------------
% AMD Kaveri, FP64
fprintf("----------------------------------------------------------------------\n")
clear
mr=4; nr=6;
Sdata=8;

SL1=16; WL1=4; NL1 = 64; CL1 = SL1 / (WL1 * NL1);
kc = model_level(SL1, NL1, CL1, WL1, Sdata, mr, nr);

SL2=2048; WL2=16; NL2 = 2048; CL2 = SL2 / (WL2 * NL2);
mc = model_level(SL2, NL2, CL2, WL2, Sdata, kc, nr);
fprintf("AMD Kaveri, FP64:        kc = %d, mc = %d\n", kc, mc);

% ----------------------------------------------------------------------------
% TI C6678, FP64
fprintf("----------------------------------------------------------------------\n")
clear
mr=4; nr=4;
Sdata=8;

SL1=32; WL1=4; NL1 = 64; CL1 = SL1 / (WL1 * NL1);
kc = model_level(SL1, NL1, CL1, WL1, Sdata, mr, nr);

SL2=512; WL2=4; NL2 = 2048; CL2 = SL2 / (WL2 * NL2);
mc = model_level(SL2, NL2, CL2, WL2, Sdata, kc, nr);
fprintf("TI C6678, FP64:          kc = %d, mc = %d\n", kc, mc);
fprintf("----------------------------------------------------------------------\n")
clear
mr=8; nr=8;
Sdata=4;
fprintf("\tkernel %dx%d \n", mr, nr);
fprintf("----------------------------------------------------------------------\n")
SL1=64; WL1=4; NL1 = 128; CL1 = SL1 / (WL1 * NL1);
kc = model_level(SL1, NL1, CL1, WL1, Sdata, mr, nr);
%
% Br in L1 --> kc x nr = kc x 8
% 4-way --> 4 lines per set
% 1 line for Cr
% 3 lines to distribute between Ar and Br, proportionally to mr/nr = 8/8 = 1
%   --> 1 line for Ar, 1 line for Br
%
% -----------------------------------
% 0 --> Cr
% -----------------------------------
% 1 --> Ar
% -----------------------------------
% 2 --> Br
% -----------------------------------
% 3
% -----------------------------------
%
% Br takes 25% of the lines  --> 25% of L1 cache (32 KB) = 8 KB --> 2048 FP32 numbers
% Br is kc x nr, with nr = 8 --> kc --> 2048/8 = 256
%
SL2=2048; WL2=16; NL2 = 2048; CL2 = SL2 / (WL2 * NL2);
mc = model_level(SL2, NL2, CL2, WL2, Sdata, kc, nr);
%
% Ac in L2 --> mc x kc = mc x 256
% 16-way --> 16 lines per set
% 1 lines for Cr
% 15 lines to distribute between Ac and Br, proportionally to mc/nr = 256/8 = 32
%   --> 14 lines for Ac, 1 line for Br
%
% -----------------------------------
% 0 --> Cr
% -----------------------------------
% 1 --> Ac
% -----------------------------------
% 2 --> Ac
% -----------------------------------
% 3 --> Ac
% -----------------------------------
% ...
% -----------------------------------
% 14 --> Ac
% -----------------------------------
% 15 --> Br
% -----------------------------------
%
% Ac takes (14/16) of the lines  --> (14/16) ---> 90%  of L2 cache (2 MB)
% --> 1.8 MB ---> 450 K FP32 numbers.
%
% Ac is mc x kc, with kc = 256   --> ... mc = 450K/256 = 17..
%
SL3=4096; WL3=16; NL3 = 4096; CL3 = SL3 / (WL3 * NL3);
nc = model_level(SL3, NL3, CL3, WL3, Sdata, mc, kc);

% Bc en L3 --> mc x kc

fprintf("ARM Carmel, FP32:        kc = %d, mc = %d, nc = %d\n", kc, mc, nc);
fprintf("----------------------------------------------------------------------\n")
% ----------------------------------------------------------------------------
% RISC-V, FP32
% ISA 
fprintf("----------------------------------------------------------------------\n")
clear
mr=4; nr=4;
Sdata=4;
fprintf("\tkernel %dx%d \n", mr, nr);
fprintf("----------------------------------------------------------------------\n")
%SL1=1024*1024; WL1=8; NL1 = 2048 ; CL1 = 64; %SL1 / (WL1 * NL1);
SL1=16; WL1=8; NL1 = 2048 ; CL1 = SL1 / (WL1 * NL1);
kc = model_level(SL1, NL1, CL1, WL1, Sdata, mr, nr);
%
% Br in L1 --> kc x nr = kc x 8
% 4-way --> 4 lines per set
% 1 line for Cr
% 3 lines to distribute between Ar and Br, proportionally to mr/nr = 8/8 = 1
%   --> 1 line for Ar, 1 line for Br
%
% -----------------------------------
% 0 --> Cr
% -----------------------------------
% 1 --> Ar
% -----------------------------------
% 2 --> Br
% -----------------------------------
% 3
% -----------------------------------
%
% Br takes 25% of the lines  --> 25% of L1 cache (32 KB) = 8 KB --> 2048 FP32 numbers
% Br is kc x nr, with nr = 8 --> kc --> 2048/8 = 256
%
SL2=2048; WL2=16; NL2 = 2048; CL2 = SL2 / (WL2 * NL2);
mc = model_level(SL2, NL2, CL2, WL2, Sdata, kc, nr);
%
% Ac in L2 --> mc x kc = mc x 256
% 16-way --> 16 lines per set
% 1 lines for Cr
% 15 lines to distribute between Ac and Br, proportionally to mc/nr = 256/8 = 32
%   --> 14 lines for Ac, 1 line for Br
%
% -----------------------------------
% 0 --> Cr
% -----------------------------------
% 1 --> Ac
% -----------------------------------
% 2 --> Ac
% -----------------------------------
% 3 --> Ac
% -----------------------------------
% ...
% -----------------------------------
% 14 --> Ac
% -----------------------------------
% 15 --> Br
% -----------------------------------
%
% Ac takes (14/16) of the lines  --> (14/16) ---> 90%  of L2 cache (2 MB)
% --> 1.8 MB ---> 450 K FP32 numbers.
%
% Ac is mc x kc, with kc = 256   --> ... mc = 450K/256 = 17..
%
SL3=4096; WL3=16; NL3 = 4096; CL3 = SL3 / (WL3 * NL3);
nc = model_level(SL3, NL3, CL3, WL3, Sdata, mc, kc);

% Bc en L3 --> mc x kc

fprintf("RISC-V, FP32:        kc = %d, mc = %d, nc = %d\n", kc, mc, nc);
fprintf("----------------------------------------------------------------------\n")
