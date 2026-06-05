#!/bin/bash
#SBATCH --job-name=2_fastqc
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=!!EDIT FOR NUMBER OF FASTQS, 1 HOUR PER!! 1:00:00
#SBATCH --output=/scratch/atran/final/2_fastqc/2_fastqc.log
#SBATCH --error=/scratch/atran/final/2_fastqc/2_fastqc.err


# Choose one of the following fashion
#SBATCH --mem=300MB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

#the sbatch variables were determined from:
#https://rcs.ucalgary.ca/Bioinformatics_applications

ml FastQC/0.11.5
ml multiqc/1.7
 
dir_in=/scratch/atran/final/1_reads/wgs
fastq=${dir_in}/*.fa*
dir_out=/scratch/atran/final/2_fastqc/ 

fastqc -o $dir_out --noextract --nogroup -f $fastq > ${dir_out}/fastqc.log
multiqc -m fastqc -n ${dir_out}/multiqc/report -v ${dir_out}/ > ${dir_out}/multiqc/multiqc.log
