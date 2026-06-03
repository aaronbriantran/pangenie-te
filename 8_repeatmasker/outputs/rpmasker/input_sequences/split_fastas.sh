#!/bin/bash
#SBATCH --job-name=split_fasta
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=0:10:00
#SBATCH --output=/scratch/atran/final/8_repeatmasker/logs/8_splitfasta_%a.log
#SBATCH --error=/scratch/atran/final/8_repeatmasker/logs/8_splitfasta_%a.err
#SBATCH --array=1,7,9

# Choose one of the following fashion
#SBATCH --mem=50MB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

ml samtools

donorname=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $3}' /scratch/atran/final/3_pangenie/pangenie_input.csv)
outputNull="./${donorname}_rpmasker_null.fa"
outputAlt="./${donorname}_rpmasker_alt.fa"

isNull=-1
while read line; do
        if [[ "${line}" == ">"* ]]; then
                if [[ "${line}" == *"NULL"* ]]; then
                        isNull=1
                        echo "${line}" >> $outputNull
                else
                        isNull=0
                        echo "${line}" >> $outputAlt
                fi
        else
                if (( isNull == 1 )); then
                        #append to null
                        echo "${line}" >> $outputNull
                else
                        #append to alt
                        echo "${line}" >> $outputAlt
                fi
        fi
done < ${donorname}_rpmasker.fa
