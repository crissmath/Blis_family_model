set terminal postscript color font "Helvetica, 16" enhanced 
set xlabel font ",22" "Microkernel dimensions (m_r x k_r)"
set ytics
set grid ytics
set style data histograms
set style histogram rowstacked
set style fill solid border -1
set boxwidth 0.75
set grid ytics


labels = "'None' \
          'Pack B_c' \
          'Pack C_c' \
          'Unpack C_c' \
          'Copy B_r' \
          'Stream A_r' \
          'Stream B_r' \
          'Stream C_c' \
          'Arithm'"

set output "time_B3A2C0.eps"
set ylabel font ",22" "Time (s)"
set datafile separator ","
unset key
set key top right box Left reverse  maxrows 8
plot 'time_B3A2C0.txt'  using (16):xtic(1) , \
                     '' using (15) , \
                     '' using (14) , \
                     '' using (13) , \
                     '' using (12) , \
                     '' using (11) , \
                     '' using (10) , \
                     '' using (9) , \
                     '' using (8) , \
                     '' using (7) , \
                     '' using (6) , \
                     '' using (5) , \
                     '' using (4) , \
                     '' using (3) , \
                     '' using (2) 
