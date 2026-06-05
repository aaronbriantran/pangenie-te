#!/bin/bash
#SBATCH --job-name=index_ref
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --time=1:00:00
#SBATCH --output=/scratch/atran/final/3_pangenie/logs/index_ref.log
#SBATCH --error=/scratch/atran/final/3_pangenie/logs/index_ref.err

# Choose one of the following fashion
#SBATCH --mem=10GB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

ml samtools

samtools faidx ./CHM13v11Y.fa 
