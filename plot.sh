#!/bin/sh

#clean previos graphs
echo "delete previus graphs.."
find . -type f -name '*.eps' -delete
find . -type f -name '*.pdf' -delete

# simple gnuplot execute m script
gnuplot /home/crirabe/Blis_family_model/data/plots/plots.gp
echo "plots generate..."

echo "start conversion esp to pdf..."
for f in "/home/crirabe/Blis_family_model/data/plots/"*.eps
	do
	echo "$f"
	epstopdf "$f"
done
echo "conversion done...."
