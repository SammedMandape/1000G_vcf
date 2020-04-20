""" This script reads multiple single line fasta file and 
    creates bed files of homopolymer region."""
import os
import re

# location of fasta file input directory
directory="."
# set threshold to define homopolymers
threshold = 2

def homopolymer_region(input_file,output_file):
    """This creates bed file for homopolymer region except Ns.
       @param input_file: fasta file in a single line format
       @param output_file: name of the bed file to write output
       @return: bed file for homopolymer regions"""
    print(input_file)
    with open(input_file, 'r') as in_fh, open(output_file,'w') as out_fh:
        chr = ""
        for line in in_fh:
            if line.startswith('>'):
                chr = "chr" + re.match(r'>(\d+).*',line).group(1)
            else:
                # k tracks last homopolymer region's end index so that the homoploymeric region isn't repeated
                k=0
                line1 = line.strip()
                # i is 0 based index of the starting bp of homopolymer
                for i in range(0, len(line1)):
                    print(i)
                    if(i<k or line1[i] == "N"):
                        continue
                    #print(i)
                    j=0
                    j = i+1
                    if(j >= len(line1)):
                            break
                    while line1[i] == line1[j]:
                        j += 1
                        if(j >= len(line1)):
                            break
                 
                    if j-i > threshold:
                        if (j != k) and (line1[i] != "N"):
                            print("{0}\t{1}\t{2}\t{3}\n".format(chr, i, j, line1[i]))
                            out_fh.write("{0}\t{1}\t{2}\t{3}\n".format(chr, i, j, line1[i]))
                            k=j
                   

for filenames in os.listdir(directory):
    if re.match(r'.*\.fasta$', filenames) is not None:
        infile = directory + "/" + filenames
        outfile = re.match(r'(Homo_sapiens\.GRCh38\.dna\.chromosome\.\d+)\.fasta',filenames).group(1) + "homoploymer_region.bed"
        homopolymer_region(infile,outfile)



        
        
        
# seq = "AACCCTAACCCCCCCCCCCCTAACCCTAACCCTAACCCTAACCCCCCCCCCCCCCCCCCNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN"     
# threshold = 2
# k=0
# for i in range(0, len(seq)):   
    # j=0
    # j = i+1
    
    # if(j>=len(seq)):
            # break
    
    # while seq[i]==seq[j]:
        # j += 1
        
        # if(j>=len(seq)):
            # break
 
    # if j-i > threshold:
        # if (j != k) and (seq[i] != "N"):
            # print(i, j, seq[i])
        # k=j