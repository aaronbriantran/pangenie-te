#!/bin/bash

#This script uses bcftools isec to create the bcfs of variants that are in not phased because they are not in HPRC2 or are just not phased for other reasons.

sample=''
phased=''
panel=''
output_dir=''

print_usage() {
	printf "-s is for the merged sample set, -h is for the phased set, -l for the panel, -o is for the output directory prefix" 
}

while getopts 's:h:l:' flag; do
	case "${flag}" in
		s) sample="${OPTARG}" ;;
		h) phased="${OPTARG}" ;;
		l) panel="${OPTARG}" ;;
		o) output_dir="${OPTARG}" ;;
		*) print_usage
		   exit 1 ;;
	esac
done


#all variants that are in the sample, not phased, but in the panel
bcftools isec "${sample}" "${phased}" "${panel}" -p "${output_dir}" -n~101
#all variants that are in the sample but not phased because not in panel
bcftools isec "${sample}" "${phased}" "${panel}" -p "${output_dir}" -n~100
