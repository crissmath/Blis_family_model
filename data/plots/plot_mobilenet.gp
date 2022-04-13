set terminal postscript color size 20,6 font "Helvetica, 16" enhanced 
set ytics
set grid ytics
set style data histograms
set style fill solid border -1

# bars with 
set grid ytics
set yrange [0:40]
#set xrange[-5:25]

set output "time_best_mobilenetv1_group.eps"
set xlabel font ",24" "#Layer ID"
set ylabel font ",24" "Time (s)"
set key top left box Left maxrows 3
set style histogram

set key font ",24"

set boxwidth 1

set bmargin 8
set xtics rotate by 40 right
set xtics  10
set xtics font ", 22"

plot 'time_best_mobilenet_group.dat' using 2:xtic(1) t "B3A2C0" ls 1, \
                            '' using 3 title "B3C2A0"     ls 4, \
                            '' using 4 title "C3B2A0"     ls 6, \
