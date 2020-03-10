#! /bin/bash

read -p 'FilePath: ' bedtl

for i in $bedtl/*.vcf
do

echo $i
filename=$(basename $i .vcf)
bedtools intersect -sorted -wb -a CODIS_core_loci_8K_hg38_sorted.bed -b $filename.vcf > ./$filename.txt

done
