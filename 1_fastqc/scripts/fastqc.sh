#!/bin/bash

#author Aaron Tran
#date 8 June 2026
#use This script runs fastqc on a given fasta file
#input $1 is a given fastq file (so it does not measure pairs of files)
#output an unzipped report, given as $2
#args $3 is the log directory
#compute 10 cores, 1400 Mb, maybe 5-10 minutes per file?, taken from https://rcs.ucalgary.ca/Bioinformatics_applications

ml fastqc/0.12.1

#runs the fastqc
# -o takes output directory, --extract unzips output reports, --delete removes zipped reports after, file taken as an argument
fastqc \
   -o "$2" \
   --extract \
   --delete \
   --threads number of threads \
   "$1" &>> "$3"/fastqc.log