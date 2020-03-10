#! /bin/bash

read -p 'FilePath: ' filevcf
for i in $filevcf/*.gz
do

echo $i
filename=$(basename $i .phased.vcf.gz)
zgrep -v "##" $i | cut -f-8 > ./$filename.vcf
sed -i '1s/^/##fileformat=VCFv4.3\n/' $filename.vcf


done 

