python GOfull.py
python Fixfull.py

#Replace erroneous characters that will effect fasttree to break/return duplicate sequences
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i '/^<!DOCTYPE/d' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i 's/:/_/' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i 's/,/_/' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i 's/(/_/' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i 's/)/_/' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i 's/_\{2,\}/_/g' {} \;

#Remove Duplicates
find . -maxdepth 1 -name "fixed*.fa" -exec seqkit rmdup -n {} -o concatenated_ready_seq.fa \;

#Alignment Run MAFFT
mafft --auto concatenated_ready_seq.fa > aligned_seq.fa

#Trimming of Alignment Run Trimal*
trimal -fasta -in aligned_seq.fa -out trimmed_seq.fa

#Phylogeny - Run fasttree
FastTree -quiet trimmed_seq.fa > treefile 
cat filename.txt | xargs mkdir
cat filename.txt | xargs mv treefile
cat filename.txt | xargs mv concatenated_ready_seq.fa
cat filename.txt | xargs mv concatenated_ready_seq.fa
rm aligned_seq.fa
rm trimmed_seq.fa
rm filename.txt


