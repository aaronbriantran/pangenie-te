#!/bin/bash
#SBATCH --job-name=limeaid
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:10:00
#SBATCH --output=/scratch/atran/final/8_repeatmasker/logs/8_limeaid_%a.log
#SBATCH --error=/scratch/atran/final/8_repeatmasker/logs/8_limeaid_%a.err
#SBATCH --array=1

# Choose one of the following fashion
#SBATCH --mem=100MB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

donorname=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $3}' /scratch/atran/final/3_pangenie/pangenie_input.csv)
vcffile="/scratch/atran/final/3_pangenie/vcfs/${donorname}_genotyping_biallelic.vcf"
reffasta="/scratch/atran/final/3_pangenie/input_files/CHM13v11Y.fa"
tablefile="/scratch/atran/final/8_repeatmasker/outputs/insertion_tables/${donorname}_insertions.txt"
maskfasta="/scratch/atran/final/8_repeatmasker/outputs/rpmasker/input_sequences/${donorname}_rpmasker_alt.fa"

outputs="/scratch/atran/final/8_repeatmasker/outputs"

# Adding this line should be good
eval "$(conda shell.bash hook)"
conda activate limeaid


python /scratch/atran/final/8_repeatmasker/L1ME-AID/limeaid.v1.4-beta.py -i ${maskfasta} -r ${outputs}/rpmasker/out_tables/${donorname}_alt_filtered.out -o ${outputs}/limeaid/${donorname}_alt_filtered.outFile
