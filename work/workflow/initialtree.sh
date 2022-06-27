python fixFile.py 
seqkit rmdup -n full.fasta -o concatenated_ready_seq.fa -d deleted.fa
mafft --auto concatenated_ready_seq.fa > aligned_seq.fa # no methods applicable as a large number of sequences
trimal  -fasta -gappyout -in aligned_seq.fa -out trimmed_seq.fa #ruins results -gappyout
FastTree -quiet trimmed_seq.fa > newtreefile #dont want to use psuedo as there is a high similarity / wag bad