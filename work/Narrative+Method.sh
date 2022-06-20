#1. Use Pfam to get HMM Profiles
#Make multiple trees comparing domains, sameish results PPK1-4
#PFAM website
#2. Use HMM Profiles to seach EBI's Reference Proteomes from Uniprot
#DO on EBI's website - download results as regular fasta
#3. Format results 
python GOfull.py
python Fixfull.py
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i '/^<!DOCTYPE/d' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i 's/:/_/' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i 's/,/_/' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i 's/(/_/' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i 's/)/_/' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec sed -i 's/_\{2,\}/_/g' {} \;
find . -maxdepth 1 -name "fixed*.fa" -exec seqkit rmdup -n {} -o concatenated_ready_seq.fa \;

#4. Run phylogeny (Mafft,Trimal,FastTree)
mafft --auto concatenated_ready_seq.fa > aligned_seq.fa
trimal -fasta -in aligned_seq.fa -out trimmed_seq.fa
FastTree -quiet trimmed_seq.fa > treefile


#5. Prune FastTree (Python,MAFFT,Trimal)
#Prune on ITOL export pruned tree as newick format with NO internal node IDs to get prunedtree.nwk and used concatenated_ready_seq.fa 
#get names
python -c "exec(\"import sys\nimport sys\nfrom ete3 import Tree\nt = Tree('prunedtree.nwk',format=1)\nnames=t.get_leaf_names()\nwith open('listfile.txt', mode='w') as file:\n  for listitem in names:\n    file.write(listitem+str('\\\n'))\")"
#make concatenated_ready_seq.fa single files fasta
python single_line.py
#return matching pruned sequences from "master" sequence file
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
mv trimmed_seq.fa pruned_tree.fasta

#6. Run Phylogeny on Pruned FastTree (IQTree)
iqtree -nt AUTO  -s pruned_tree.fasta


#7. Do on a machine with lots of storage (e.g. ISCA)
#Download MMETSP
wget https://zenodo.org/record/3247846/files/mmetsp_dib_trinity2.2.0_pep_zenodo.tar.gz
tar -xvf mmetsp_dib_trinity2.2.0_pep_zenodo.tar.gz
#Download TARA
wget wwwuser.gwdg.de/~compbiol/metaeuk/2019_11/MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas.gz
gunzip MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas.gz

#Build hmmprofiles for the 6000 sequences and the 43 in the refined tree
#grab trimmed_seq_all.fa from folder 4
hmmbuild PP_kinase_all.hmm trimmed_seq_all.fa 
#grab pruned_tre.fasta from folder 5
hmmbuild PP_kinase_refined.hmm trimmed_seq_refined.fa

#10. HMMSearch Tara and MMETSP
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhitsMMETSP.sto PP_kinase_all.hmm MMETSP.pep &
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhitsTara.sto PP_kinase_all.hmm MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas &

nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhitsEukMMETSP.sto PP_kinase_euk.hmm MMETSP.pep &
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhitsTaraEuk.sto PP_kinase_euk.hmm MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas &

esl-reformat fasta myhitsMMETSP.sto > hitsMMETSP.fa
esl-reformat fasta myhitsTara.sto > hitsTara.fa

esl-reformat fasta myhitsEukMMETSP.sto > hitsEukMMETSP.fa
esl-reformat fasta myhitsTaraEuk.sto > hitsTaraEuk.fa

#fix MMETSP files
python fixMMETSP.py
#fix Tara files
sed -i 's/|[^|]*//2g' hitsTara.fa
sed -i 's/|/_/g' hitsTara.fa

#11. Remove sequences <600 peptides
seqkit seq -m 300 your_fasta.fa
#12. Use Raxml EPA or PPLACER to place these significant hits on the IQ tree.