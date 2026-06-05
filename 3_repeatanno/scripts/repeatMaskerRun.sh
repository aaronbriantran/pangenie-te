#!/bin/bash
#SBATCH --job-name=repeatmasker
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --time=3:30:00
#SBATCH --output=/scratch/atran/final/8_repeatmasker/logs/8_repeatmasker_%a.log
#SBATCH --error=/scratch/atran/final/8_repeatmasker/logs/8_repeatmasker_%a.err
#SBATCH --array=1,7,9

# Choose one of the following fashion
#SBATCH --mem=10GB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

ml samtools

donorname=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $3}' /scratch/atran/final/3_pangenie/pangenie_input.csv)
vcffile="/scratch/atran/final/3_pangenie/vcfs/${donorname}_genotyping_biallelic.vcf"
reffasta="/scratch/atran/final/3_pangenie/input_files/CHM13v11Y.fa"
tablefile="/scratch/atran/final/8_repeatmasker/outputs/insertion_tables/${donorname}_insertions.txt"
maskfastanull="/scratch/atran/final/8_repeatmasker/outputs/rpmasker/input_sequences/${donorname}_rpmasker_null.fa"
maskfastaalt="/scratch/atran/final/8_repeatmasker/outputs/rpmasker/input_sequences/${donorname}_rpmasker_alt.fa"

../RepeatMasker/RepeatMasker -species human -s -pa 20 -gff $maskfastanull
../RepeatMasker/RepeatMasker -species human -s -pa 20 -gff $maskfastaalt
