#!/bin/bash

#1. MAJOR DO THIS -> concatenate fasta sequences from each hmm from each part of structure into one sequence for each organism
#2. MAJOR DO THIS -> Fix trimal
python FixID.py




#Remove Duplicates
seqkit rmdup -s fixedtestfile.fa -o seqs_without_duplicate.fa
seqkit rmdup -n seqs_without_duplicate.fa -o seqs_without_duplicate2.fa
#Concatenate Identical Taxas
awk '/^>/ {if(prev!=$0) {prev=$0;printf("\n%s\n",$0);} next;} {printf("%s",$0);} END {printf("\n");}' seqs_without_duplicate2.fa > concatenated_seq.fa
#Run MAFFT
mafft --auto concatenated_seq.fa > aligned_seq.fa

#Run Trimal*
trimal -clustal -in aligned_seq.fa -out trimmed_seq.fa

#Run IQTREE
#iqtree -nt AUTO  -s aligned_seq.fa
iqtree -nt AUTO  -s trimmed_seq.fa
cat filename.txt | xargs mkdir
cat filename.txt | xargs mv *log 
cat filename.txt | xargs mv *iqtree
rm ./aligned*
rm ./trimmed*
rm ./concatenated*
rm seqs_without_duplicate.fa
rm seqs_without_duplicate2.fa
rm fixed*.fa
rm filename.txt


