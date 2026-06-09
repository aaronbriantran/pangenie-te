#!/bin/bash

#author Aaron Tran
#date 9 June 2026
#use This script runs MultiQC on all of the FastQC reports to convert them into a readable format
#input $1 is the results directory of the FastQC reports
#output $2 is the output directory for where MultiQC should put its reports
#args $3 is the environment yaml file for the conda environment that wraps multiqc, $4 is the log directory
#compute 10 cores, 1400 Mb, maybe 5-10 minutes per file? inherited directly from fastqc.sh

#logic for creating conda environments if they aren't in your environment list
if conda info --envs | grep -q multiqc; then
   conda env create --file "$3"
fi

conda activate multiqc

#run multiqc
#-n is the name of the report, -o is the output directory (in results), -m is the module
#for multiqc (inherited from Kara), -v forces verbose reporting
#takes the directory of FastQC data as the argument, and passes stderr and stdout to the log file
multiqc \
   -n report \
   -o "$2" \
   -m fastqc \
   -v \
   "$1" &> "$4"/multiqc.log