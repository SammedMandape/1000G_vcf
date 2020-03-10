import os
import re
directory = input("Enter directory: ")
#os.chdir(directory)

def multi_2_one_fa(input_file, output_file):
    print(os.getcwd())
    #output_file = re.match(r'(.*\.\d+)\.fa$',input_file).group(1) + ".fasta"
    #print(output_file)
    with open (input_file, 'r') as infile, open(output_file, 'w') as outfile:
        block = []
        #[print(line) for line in infile]
        for line in infile:
            if line.startswith('>.*'):
                if block:
                    outfile.write(''.join(block) + '\n')
                    block = []
                outfile.write(line)
            else:
                block.append(line.strip())
            
        if block:
            outfile.write(''.join(block) + '\n')
            

for filename in os.listdir(directory):
    if re.match(r'.*\.\d+\.fa$',filename) is not None:
        infile = directory + "/" + filename
        outfile = re.match(r'(.*\.\d+)\.fa$',filename).group(1) + ".fasta"
        multi_2_one_fa(infile, outfile)