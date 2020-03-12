"""position and number of nucleotide in homopolymer region"""

seq = "AACCCTAACCCCCCCCCCCCTAACCCTAACCCTAACCCTAACCCCCCCCCCCCCCCCCC"
#seq = "AACCCTAACCC"
threshold = 2
k=0
for i in range(0, len(seq)):   
    j=0
    j = i+1
    
    if(j>=len(seq)):
            break
    
    while seq[i]==seq[j]:
        j += 1
        
        if(j>=len(seq)):
            break
 
    if j-i > threshold:
        if (j != k):
            print(i, j)
        k=j