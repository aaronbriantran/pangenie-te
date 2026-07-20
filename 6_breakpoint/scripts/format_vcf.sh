#!/bin/bash

results=results/te_match

awk -v end=$1 'BEGIN{FS=OFS="\t"}
{
  out=$1
  for(i=2;i<=end;i++) out=out OFS $i
  print out
}' ${2} > ${3}
