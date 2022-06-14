#if there is a filecalled prunedtree.nwk in the current directory, then it will be used as the tree to be pruned.


#Write names in pruned tree to a file called names.txt
python -c 'import sys; from ete3 import Tree; t = Tree(sys.argv[1],quoted_node_names=True,format=1);print(t.get_leaf_names());' prunedtree.nwk > names.txt
#Use names to gather all sequences in pruned tree.
cat names.txt | while read line; do grep -wns "$line" concatenated_ready_seq.fa -A 1; done > newick_seq_line.txt
#Now that we have all the sequences in our pruned tree run a regular MAFFT and Trimal followed by IQTREE

mafft --auto concatenated_ready_seq.fa > aligned_seq.fa
sed -i 's/:/_/' aligned_seq.fa
sed -i 's/:/_/' aligned_seq.fa
sed -i 's/,/_/' aligned_seq.fa
sed -i 's/(/_/' aligned_seq.fa
sed -i 's/)/_/' aligned_seq.fa
sed -i 's/_\{2,\}/_/g' aligned_seq.fa

trimal -fasta -in aligned_seq.fa -out trimmed_seq.fa

#Run IQTREE
iqtree -nt AUTO  -s trimmed_seq.fa
