#!/bin/bash

read1=''
read2=''
inputdir=''
output=''
log=''
threads=''
mem=''

#TODO fix pathing to inputs, wait for other scripts first

print_usage() {
   printf "1 for read1, 2 for read2, o for output, l for log, t for threads... maybe 32, m for mem, i for index directory"
}

while getopts "1:2:o:l:t:m:" flag; do
   case "${flag}" in
      1) read1="${OPTARG}" ;;
      2) read2="${OPTARG}" ;;
      o) output="${OPTARG}" ;;
      l) log="${OPTARG}" ;;
      t) threads="${OPTARG}" ;;
      m) mem="${OPTARG}" ;;
      i) inputdir="${OPTARG}" ;;
      *) print_usage
         exit 1 
   esac
done

vg giraffe \
   --progress \
   -t "${threads}" \
   -d "${inputdir}/graph.dist" \
   -z "${inputdir}/graph.shortread.zipcodes" \
   -m "${inputdir}/graph.shortread.withzip.min" \
   -x graph.xg \
    -i -f "${read1}" -f "${read2}" \
    -o BAM -b default > "${output}" 2> "${log}"