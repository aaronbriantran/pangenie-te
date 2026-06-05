#!/bin/bash
#SBATCH --job-name=insertion_fasta
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --time=0:05:00
#SBATCH --output=/scratch/atran/final/8_repeatmasker/logs/8_writeinsertions_%a.log
#SBATCH --error=/scratch/atran/final/8_repeatmasker/logs/8_writeinsertions_%a.err
#SBATCH --array=1,7,9

# Choose one of the following fashion
#SBATCH --mem=15MB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

donorname=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $3}' /scratch/atran/final/3_pangenie/pangenie_input.csv)
vcffile="/scratch/atran/final/3_pangenie/vcfs/${donorname}_GQ_ins.vcf"

awk 'BEGIN {FS=" "; print "chr", "pos", "leftFlank", "endOfInsert", "lengthOfInsert", "rightFlank", "altAllele"} !/^#/ && $3 ~ /INS/ {
	# if the ID field has the word INS in it
	# find the genotype and its phred quality in field 10
	split($10, field10, ":", seps)
	chr=$1
	pos=$2
	altAllele=$5
	lengthOfInsert=length($5)
	leftFlank=((pos-1000))
	endOfInsert=((pos+lengthOfInsert)
	rightFlank=((pos+1000))

	print chr, pos, leftFlank, endOfInsert, lengthOfInsert, rightFlank, altAllele

	#if there is an alt insertion, and if the phred score is greater than 50
	#if (index(field10[1], "1") != 0) {
	#	if (field10[2] > 50) {
	#		lengthOfInsert=length($5)
	#		if (lengthOfInsert > 250) {
	#			#if the length of the insertion (assumed in the ALT allele) is > 250 bp

				#get the chr, get the leftFlank, pos, endOfInsert, rightFlank, altAllele
	#			chr=$1
	#			pos=$2
	#			leftFlank=((pos-1000))
	#			endOfInsert=((pos+lengthOfInsert))
	#			rightFlank=((pos+1000))
	#			altAllele=$5

	#			print chr, pos, leftFlank, endOfInsert, lengthOfInsert, rightFlank, altAllele
	#		}
	#	}
	#}
}' ${vcffile} > ../outputs/insertion_tables/${donorname}_insertions.txt
