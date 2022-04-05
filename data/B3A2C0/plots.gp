set terminal postscript color font "Helvetica, 10" enhanced 

set xlabel font ",15" "Microkernel dimensions (m_r x k_r)"
set ytics
set grid ytics
set style data histograms
set style histogram rowstacked
set style fill solid border -1
# bars with 
set boxwidth 0.8
set grid ytics

set key top left box Left reverse maxrows 2
set output 'plot.eps'

labels = "'None' \
         'Pack B_c' \
         'Pack C_c' \
         'Unpack C_c' \
         'Copy B_r' \
         'Stream A_r' \
         'Stream B_r' \
         'Stream C_c' \
         'Arithm'"

plot 'time_B3A2C0.dat' using 9 t word(labels, 9),  \
                    '' using 8 t word(labels, 8),  \
                    '' using 7 t word(labels, 7),\
                    '' using 6 t word(labels, 6),\
                    '' using 5 t word(labels, 5),\
                    '' using 4 t word(labels, 4),\
                    '' using 3 t word(labels, 3),\
                    '' using 2:xtic(1) t word(labels, 2)\