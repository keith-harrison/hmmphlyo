#!/bin/bash
#Implement Previous Steps*
#1. INPUT PROTEIN SEQUENCE AND GET HMM FROM PFAM
#2. PUT THIS HMM INTO HMMER3 
#3. GET THE HITS FROM HMMER3 in form of fasta sequences
#4. MAJOR DO THIS -> Take the HMM for each part of structure -> GET SEQUENCES FOR EACH PART AND concatenate
#Python File Run
python FixID.py



#Concatenate Identical Taxas
awk '/^>/ {if(prev!=$0) {prev=$0;printf("\n%s\n",$0);} next;} {printf("%s",$0);} END {printf("\n");}' seqs_without_duplicate.fa > concatenated_seq.fa
#Remove Duplicates
seqkit rmdup -s fixedtestfile.fa -o seqs_without_duplicate.fa
#Run MAFFT
mafft --auto concatenated_seq.fa > aligned_seq.fa

#Run Trimal*
#trimal -clustal -in aligned_seq.fa -out trimmed_seq.fa

#Run IQTREE
iqtree -nt AUTO  -s aligned_seq.fa
#iqtree -nt AUTO  -s trimmed_seq.fa

cat filename.txt | xargs mkdir
cat filename.txt | xargs mv *log 
cat filename.txt | xargs mv *iqtree
rm ./aligned*
#rm ./trimmed*
rm ./concatenated*
rm seqs_without_duplicate.fa
rm fixed*.fa
rm filename.txt

