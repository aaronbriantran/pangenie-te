#!/bin/bash

results=results/te_match

awk 'BEGIN{FS=OFS="\t"}
{
  n=split($3,id,"-")
  vtype=id[3]          # INS/DEL from ID
  vlen=id[n]           # trailing length from ID

  blen=$17             # BED length (col after TE name)
  btype=$19            # BED variant type

  if(vtype!=btype) next
  if(blen==0 || vlen==0) next
  ratio=(vlen>blen)?vlen/blen:blen/vlen
  if(ratio>1.10) next

  out=$1
  for(i=2;i<=12;i++) out=out OFS $i
  print out
}' ${results}/any_phased_repeat_intersect.txt > ${results}/matched_vcf_body.txt
