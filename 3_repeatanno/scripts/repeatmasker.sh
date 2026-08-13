#!/bin/bash
#SBATCH --job-name=repeatmasker
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --time=6:00:00
#SBATCH --output=/scratch/atran/pangenie-te/3_repeatanno/logs/repeatmasker.log
#SBATCH --error=/scratch/atran/pangenie-te/3_repeatanno/logs/repeatmasker.err

# Choose one of the following fashion
#SBATCH --mem=20GB


set -e

ins_fa="results/pangenie_total_ins.fa"
out_dir="results/repeatmasker"

mkdir -p $out_dir

RepeatMasker -s -species human -uncurated -pa 4 -dir ${out_dir} ${ins_fa}
