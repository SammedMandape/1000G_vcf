#! /bin/bash

read -p 'FilePath: ' filevcfgz
for i in $filevcfgz/*.gz
do
    echo $i
    filename=$(basename $i .vcf.gz)
    #echo $filename.phased.vcf.gz
    #bedtools intersect -wb -sorted -a CODIS_core_loci_8K_hg38_sorted.bed -b /home/data/LabData/HumanGenomes/1000Genomes_HG38/ALL.chr1.shapeit2_integrated_v1a.GRCh38.20181129.phased.vcf.gz
    bedtools intersect -wb -sorted -a CODIS_core_loci_8K_hg19_sorted.bed -b $i > $filevcfgz/$filename\_all.txt

done

