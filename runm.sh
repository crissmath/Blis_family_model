#!/bin/sh

# simple matlab execute m script
if [ $# -eq 0 ]
    then
        echo "need m script : runm script.m"
fi

matlab -nodisplay -nosplash -nodesktop -r "run('./test.m');exit;"| tail -n +10

