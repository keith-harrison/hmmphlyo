#Prune FastTree (Python,MAFFT,Trimal)

#Prune on ITOL export pruned tree as newick format with NO internal node IDs to get prunedtree.nwk and used concatenated_ready_seq.fa 
python -c "exec(\"import sys\nimport sys\nfrom ete3 import Tree\nt = Tree('prunedtree.nwk',format=1)\nnames=t.get_leaf_names()\nwith open('listfile.txt', mode='w') as file:\n  for listitem in names:\n    file.write(listitem+str('\\\n'))\")"

#make concatenated_ready_seq.fa single lined fasta
python single_line.py 

#return matching pruned sequences from "master" sequence file
cat listfile.txt | grep -A 1 --no-group-separator -f - fixedconcatenated_ready_seq.fa > newick_seq_line.fa

#Now that we have all the sequences in our pruned tree run a regular MAFFT and Trimal followed by IQTREE
mafft --auto newick_seq_line.fa > aligned_seq.fa
trimal -fasta -in aligned_seq.fa -out trimmed_seq.fa
mv trimmed_seq.fa pruned_tree.fasta

nohup iqtree -nt AUTO -s pruned_tree.fasta -bb 1000 -pre pruned &