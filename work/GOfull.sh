python GOfull.py
python Fixfull.py
#find fixed* | sed '/^<!DOCTYPE/d' fixed*.fa > tempfile.fa
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i '/^<!DOCTYPE/d' {} \;
#Remove Duplicates
find . -maxdepth 1 -name "fixed*.fa" -exec seqkit rmdup -n {} -o concatenated_ready_seq.fa \;

#Run MAFFT
mafft --auto concatenated_ready_seq.fa > aligned_seq.fa

#Run Trimal*
trimal -clustal -in aligned_seq.fa -out trimmed_seq.fa

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
rm full*.fa

