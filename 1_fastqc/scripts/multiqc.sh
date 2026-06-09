#!/bin/bash

#author Aaron Tran
#date 9 June 2026
#use This script runs MultiQC on all of the FastQC reports to convert them into a readable format
#input $1 is the results directory of the FastQC reports
#output $2 is the output directory for where MultiQC should put its reports
#args $3 is the environment yaml file for the conda environment that wraps multiqc, $4 is the log directory
#compute ???

if conda info --envs | grep -q multiqc; then
   conda create --file "$3"
fi

conda activate multiqc

multiqc \
   -n report \
   -o "$2" \
   -m fastqc \
   -v \
   "$1" > "$4"/multiqc.log