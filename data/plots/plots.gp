set terminal postscript color font "Helvetica, 15" enhanced 
set ytics
set grid ytics
set style data histograms
set style histogram rowstacked
set style fill solid border -1
# bars with 
set boxwidth 0.75
set grid ytics
set yrange [0:60]


set key top left box Left reverse maxrows 2

labels = "'None' \
         'Pack B_c' \
         'Pack C_c' \
         'Unpack C_c' \
         'Copy B_r' \
         'Stream A_r' \
         'Stream B_r' \
         'Stream C_c' \
         'Arithm'"

set title "(a) B3A2C0" font "Helvetica, 15" enhanced 
set xlabel font ",22" "Microkernel dimensions (m_r x n_r)"
set ylabel font ",22" "Time (s)"
set output '~/Blis_family_model/data/plots/time_all_B3A2C0.eps'
plot "<(sed -n '1,10p; 14,15p; 20p; 26p; 32p' ~/Blis_family_model/data/plots/time_B3A2C0.dat)" using 9 t word(labels, 9),  \
                               '' using 8 t word(labels, 8),  \
                               '' using 7 t word(labels, 7),\
                               '' using 6 t word(labels, 6),\
                               '' using 5 t word(labels, 5),\
                               '' using 4 t word(labels, 4),\
                               '' using 3 t word(labels, 3),\
                               '' using 2:xtic(1) t word(labels, 2)\

set title "(b) B3C2A0" font "Helvetica, 15" enhanced 
set xlabel font ",22" "Microkernel dimensions (m_r x k_r)"
set output '~/Blis_family_model/data/plots/time_all_B3C2A0.eps'
plot "<(sed -n '1,10p; 14,15p; 20p; 26p; 32p' ~/Blis_family_model/data/plots/time_B3C2A0.dat)"   using 9 t word(labels, 9),  \
                                '' using 8 t word(labels, 8),  \
                                '' using 7 t word(labels, 7),\
                                '' using 6 t word(labels, 6),\
                                '' using 5 t word(labels, 5),\
                                '' using 4 t word(labels, 4),\
                                '' using 3 t word(labels, 3),\
                                '' using 2:xtic(1) t word(labels, 2)\

                                
set title "(C) C3B2A0" font "Helvetica, 15" enhanced 
set xlabel font ",22" "Microkernel dimensions (m_r x k_r)"
set output '~/Blis_family_model/data/plots//time_all_C3B2A0.eps'
plot "<(sed -n '1,10p; 14,15p; 20p; 26p; 32p' ~/Blis_family_model/data/plots/time_C3B2A0.dat)"   using 9 t word(labels, 9),  \
                                '' using 8 t word(labels, 8),  \
                                '' using 7 t word(labels, 7),\
                                '' using 6 t word(labels, 6),\
                                '' using 5 t word(labels, 5),\
                                '' using 4 t word(labels, 4),\
                                '' using 3 t word(labels, 3),\
                                '' using 2:xtic(1) t word(labels, 2)\
