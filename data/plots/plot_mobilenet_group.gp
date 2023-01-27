set terminal postscript color size 12,4 font "Helvetica, 10" enhanced 
set grid ytics
set style data histograms
set style fill solid border -1
# bars with 
set boxwidth 0.75
set yrange [0:40]
#set key width 0.8
set key height 1


set output "time_best_mobilenetv1_group.eps"
set xlabel font ",22" "#Layer ID"
set ylabel font ",22" "Time (s)"
set key top left box Left maxrows 3
set style histogram
set boxwidth 1

set xtics rotate 45
plot 'time_best_mobilenet_group.dat' using ($2):xtic(1) t "B3A2C0" ls 1, \
                            '' using ($3) title "B3C2A0"     ls 4, \
                            '' using ($4) title "C3B2A0"     ls 6, \
