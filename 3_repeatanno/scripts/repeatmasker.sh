#!/bin/bash
#SBATCH --job-name=repeatmasker
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=20
#SBATCH --time=1:00:00
#SBATCH --output=/scratch/atran/pangenie_te/3_repeatanno/logs/repeatmasker.log
#SBATCH --error=/scratch/atran/pangenie_te/3_repeatanno/logs/repeatmasker.err

# Choose one of the following fashion
#SBATCH --mem=10GB


set -e

ins_fa="pangenie_total_ins.fa"
out_dir="results/repeatmasker"

mkdir -p $out_dir

RepeatMasker -s -species human -uncurated -pa 20 -dir ${out_dir} ${ins_fa}