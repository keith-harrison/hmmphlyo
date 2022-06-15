#if there is a filecalled prunedtree.nwk in the current directory, then it will be used as the tree to be pruned.


#Write names in pruned tree to a file called names.txt
python -c "exec(\"import sys\nimport sys\nfrom ete3 import Tree\nt = Tree('prunedtree.nwk',format=1)\nnames=t.get_leaf_names()\nwith open('listfile.txt', mode='w') as file:\n  for listitem in names:\n    file.write(listitem+str('\\\n'))\")"
#Use names to gather all sequences in pruned tree.
#make concatenated_ready_seq.fa single line fasta file
python single_line.py
cat listfile.txt | grep -A 1 --no-group-separator -f - fixedconcatenated_ready_seq.fa > newick_seq_line.fa
#Now that we have all the sequences in our pruned tree run a regular MAFFT and Trimal followed by IQTREE

mafft --auto newick_seq_line.fa > aligned_seq.fa
sed -i 's/:/_/' aligned_seq.fa
sed -i 's/:/_/' aligned_seq.fa
sed -i 's/,/_/' aligned_seq.fa
sed -i 's/(/_/' aligned_seq.fa
sed -i 's/)/_/' aligned_seq.fa
sed -i 's/_\{2,\}/_/g' aligned_seq.fa

trimal -fasta -in aligned_seq.fa -out trimmed_seq.fa
mv trimmed_seq.fa pruned_tree.fa
#Run IQTREE
iqtree -nt AUTO  -s pruned_tree.fa