#!/bin/bash

#author Aaron Tran
#date 8 June 2026
#use This script runs fastqc on fasta files
#input $1 is either a single fasta file or a space-delimited list of files (note that it does not pair files up)
#output an unzipped report; its output directory is given as $2
#args $3 is the log directory, $4 is the number of threads
#compute 10 cores, 1400 Mb, maybe 5-10 minutes per file?, taken from https://rcs.ucalgary.ca/Bioinformatics_applications

ml fastqc/0.12.1

#runs the fastqc
# -o takes output directory, --extract unzips output reports, --delete removes zipped reports after, file taken as an argument
fastqc \
   -o "$2" \
   --extract \
   --delete \
   --threads $4 \
   "$1" &>> "$3"/fastqc.log