#!/bin/bash
#SBATCH --job-name=limeaid
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:10:00
#SBATCH --output=logs/limeaid.log
#SBATCH --error=logs/limeaid.err
#SBATCH --array=1

# Choose one of the following fashion
#SBATCH --mem=10GB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

mkdir -p results/limeaid

input=results/pangenie_total_ins.fa
repeatmasker=results/repeatmasker/pangenie_total_ins.fa.out
output=results/limeaid/pangenie_total_limeaid.tsv

# Adding this line should be good
eval "$(conda shell.bash hook)"
conda activate limeaid


python /scratch/atran/final/8_repeatmasker/L1ME-AID/limeaid.v1.4-beta.py -i ${input} -r ${repeatmasker} -o ${output}
