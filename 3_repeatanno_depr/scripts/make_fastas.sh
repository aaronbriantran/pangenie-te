#!/bin/bash
#SBATCH --job-name=make_fasta
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=3:00:00
#SBATCH --output=/scratch/atran/final/8_repeatmasker/logs/8_makefasta_%a.log
#SBATCH --error=/scratch/atran/final/8_repeatmasker/logs/8_makefasta_%a.err
#SBATCH --array=1,7,9

# Choose one of the following fashion
#SBATCH --mem=1GB


set -e
# set -e is important: it tells bash to exit if any errors occur. Otherwise bash will continue executing commands after error.

ml samtools

donorname=$(awk -v row="${SLURM_ARRAY_TASK_ID}" -F',' 'NR==row {print $3}' /scratch/atran/final/3_pangenie/pangenie_input.csv)
vcffile="/scratch/atran/final/3_pangenie/vcfs/${donorname}_genotyping_biallelic.vcf"
reffasta="/scratch/atran/final/3_pangenie/input_files/CHM13v11Y.fa"
tablefile="/scratch/atran/final/8_repeatmasker/outputs/insertion_tables/${donorname}_insertions.txt"

outputprefix="/scratch/atran/final/8_repeatmasker/outputs/rpmasker"

#sort the tablefile first. take away the header, sort by chr column (ascending) and then position column (ascending), and then put the header back
columnheaders=$( head -n 1 ${tablefile} )
sorted=$( tail -n +2 ${tablefile} | sort -t " " -k1,1 -k2,2n )
echo -e "${columnheaders}\n${sorted}" > ${tablefile}

#BELOW IS IF YOU WANT TO LIGATE INSERTS TOGETHER
#iterate through each line, but have an outside array that tracks lines that you want to keep together
#kind of like max() of an array, but overlap? of a position
#keep stacking up the altAllele too
#there is a miss on the overlap, you write the previous segment and you start a new segment
#make sure that the final line writes regardless!
#also make a tester file for this
#also, provide a increment so i can see how many inserts end up becoming chunked

if [[ -f "/scratch/atran/final/8_repeatmasker/outputs/rpmasker/${donorname}_rpmasker.fa" ]]; then
	rm /scratch/atran/final/8_repeatmasker/outputs/rpmasker/${donorname}_rpmasker.fa
	echo "Removed old file"
else
	echo "No file to remove"
fi

#iterate through lines, get stats and request reference sequence as flank
while read line; do
	fields=( $line )
	if [ ${fields[0]} != "chr" ]; then #if not the header
		#get the chr, leftEnd, rightEnd, and the actual insert
		chr=${fields[0]}
		pos=${fields[1]}
                altAllele=${fields[6]}
		leftEnd=${fields[2]}
		rightEnd=${fields[5]}

		#now we get the left and right flanks of reference sequence, going from leftEnd:pos and pos:rightEnd
		leftFlank=$(echo "${chr}:${leftEnd}-${pos}" | samtools faidx ${reffasta} -r /dev/stdin -n 0 | sed -n '2{p;q}')
                rightFlank=$(echo "${chr}:${pos}-${rightEnd}" | samtools faidx ${reffasta} -r /dev/stdin -n 0 | sed -n '2{p;q}')

		#null sequence must simply be the concat of both
		nullSequence=${leftFlank}${rightFlank}

		#while the flankedInsert is the altAllele along with the null reference
		flankedInsert=${leftFlank}${altAllele}${rightFlank}

		#print reference sequence
                echo ">${chr}-${pos}-NULL" >> ${outputprefix}/${donorname}_rpmasker.fa
                echo "${nullSequence}" >> ${outputprefix}/${donorname}_rpmasker.fa

		#print insert sequences
                echo ">${chr}-${pos}-ALT" >> ${outputprefix}/${donorname}_rpmasker.fa
                echo "${flankedInsert}" >> ${outputprefix}/${donorname}_rpmasker.fa

		#THIS SCRIPT WORKS ON THE ASSUMPTION THAT NO TRANSPOSABLE ELEMENTS SPAN MULTIPLE INSERTIONS 
	fi
done < ${tablefile}
