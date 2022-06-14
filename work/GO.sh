#!/bin/bash
#This takes the results of an HMMSEARCH off of EBI's online hmmsearch and produces a phylogeny from the results.
python FixID.py

find . -maxdepth 1 -name "fixed*.fa" -exec sed -i '/^<!DOCTYPE/d' {} \;


#Remove Duplicates
seqkit rmdup -s fixed*.fa -o seqs_without_duplicate.fa

#Concatenate Identical Taxas
awk '/^>/ {if(prev!=$0) {prev=$0;printf("\n%s\n",$0);} next;} {printf("%s",$0);} END {printf("\n");}' seqs_without_duplicate.fa > concatenated_seq.fa
#Double check removing duplicates
seqkit rmdup -n concatenated_seq.fa -o concatenated_ready_seq.fa
#Run MAFFT
mafft --auto concatenated_ready_seq.fa > aligned_seq.fa
sed -i 's/:/_/' aligned_seq.fa
sed -i 's/:/_/' aligned_seq.fa
sed -i 's/,/_/' aligned_seq.fa
sed -i 's/(/_/' aligned_seq.fa
sed -i 's/)/_/' aligned_seq.fa
sed -i 's/_\{2,\}/_/g' aligned_seq.fa
#Run Trimal*
trimal -fasta -in aligned_seq.fa -out trimmed_seq.fa

#Run IQTREE
iqtree -nt AUTO  -s trimmed_seq.fa
cat filename.txt | xargs mkdir
cat filename.txt | xargs mv *log 
cat filename.txt | xargs mv *iqtree
rm ./aligned*
rm ./trimmed*
rm ./concatenated*
rm seqs_without_duplicate.fa
rm fixed*.fa
rm filename.txt


