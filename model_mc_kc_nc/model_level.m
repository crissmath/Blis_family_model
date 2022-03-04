   function [ k ] = model_level( SL, NL, CL, WL, Sdata, m, n );
%
%  Purpose
%    Estimate the dimension of the panels that will fit into a given level of the cache hierarchy following the
%    principles in the paper "Analytical modeling is enough for enough for high performance BLIS" by 
%    T. M. Low et al, 2016
%
%  Inputs:
%     SL:    Size of cache level (in Kbytes)
%     NL:    Number of sets
%     CL:    Bytes per line
%     WL:    Associativity degree
%     (m,n): Parameters of the micro-tile of C in registers 
%     Sdata: Bytes per element (e.g., 8 for FP64)
%
%  Output
%     k:     Determines that a block of size k x n stays in this level of the cache
%
%  Rule of thumb: subtract 1 line from WL (associativity), which is dedicated to the
%  operand which does not reside in the cache, and distribute the rest between the two 
%  other operands proportionaly to the ratio n/m   
%  For example, with the conventional algorithm B3A2B1C0 and the L1 cache, 
%  1 line is dedicated to Cr (non-resident in cache) while the remaining lines are distributed
%  between Ar (mr x kc) and Br (kc x nr) proportionally to the ratio nr/mr to estimate kc
%
   CAr = floor( ( WL - 1 ) / (1 + n/m) )  % Lines of each set for Ar 
   CBr = ceil( ( n / m ) * CAr )          % Lines of each set for Br
%
   k = CAr * NL * CL * 2^10 / (m * Sdata);
%
%
%  End of model_level
%
