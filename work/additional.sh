#Download MMETSP
wget https://zenodo.org/record/3247846/files/mmetsp_dib_trinity2.2.0_pep_zenodo.tar.gz
tar -xvf mmetsp_dib_trinity2.2.0_pep_zenodo.tar.gz
#MMETSP Clustered UniRef90 BIG
wget wwwuser.gwdg.de/~compbiol/metaeuk/2020_TAX_DB/MMETSP_zenodo_3247846_uniclust90_2018_08_seed_valid_taxids.tar.gz
tar -xvf MMETSP_zenodo_3247846_uniclust90_2018_08_seed_valid_taxids.tar.gz
#Download TARA
wget wwwuser.gwdg.de/~compbiol/metaeuk/2019_11/MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas.gz
gunzip MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas.gz


#Download ALL protein clusters BIG
wget wwwuser.gwdg.de/~compbiol/metaeuk/2019_11/MERC_MMETSP_Uniclust50_profiles.tar.gz
tar -xvf MERC_MMETSP_Uniclust50_profiles.tar.gz

#Build hmmprofile from trimmed_seq.fa OR use PP_kinase2.hmm
hmmbuild PP_kinase_all.hmm trimmed_seq.fa
#Run hmmsearch of file against hmm profile
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhitsMMETSP.sto PP_kinase_all.hmm MMETSP.pep &
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhitsTara.sto PP_kinase_all.hmm MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas &

nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhitsMiddleMMETSP.sto PP_kinase_middle.hmm MMETSP.pep &
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhitsTaraMiddle.sto PP_kinase_middle.hmm MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas &

nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhitsEukMMETSP.sto PP_kinase_euk.hmm MMETSP.pep &
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhitsTaraEuk.sto PP_kinase_euk.hmm MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas &
#Move results back to home directory in order to use esl tools (not available on isca)

esl-reformat fasta myhitsMMETSP.sto > hitsMMETSP.fa
esl-reformat fasta myhitsTara.sto > hitsTara.fa

esl-reformat fasta myhitsMiddleMMETSP.sto > hitsMiddleMMETSP.fa
esl-reformat fasta myhitsTaraMiddle.sto > hitsTaraMiddle.fa

esl-reformat fasta myhitsEukMMETSP.sto > hitsEukMMETSP.fa
esl-reformat fasta myhitsTaraEuk.sto > hitsTaraEuk.fa

#fix MMETSP files
python fixMMETSP.py
#fix Tara files
sed -i 's/|[^|]*//2g' hitsTara.fa
sed -i 's/|/_/g' hitsTara.fa


#join onto concatenated_ready_seq.fa OR just onto eukaryote_ppk_seq.fa EUK TREE
#Write names in pruned tree to a file called names.txt
python -c "exec(\"import sys\nimport sys\nfrom ete3 import Tree\nt = Tree('prunedtree.nwk',format=1)\nnames=t.get_leaf_names()\nwith open('listfile.txt', mode='w') as file:\n  for listitem in names:\n    file.write(listitem+str('\\\n'))\")"
#Use names to gather all sequences in pruned tree.
#make concatenated_ready_seq.fa single line fasta file
python single_line.py
cat listfile.txt | grep -A 1 --no-group-separator -f - fixedconcatenated_ready_seq.fa > newick_seq_line.fa
cat longhitsEuk.fa newick_seq_line.fa > hits_concat.fa

mafft --auto hits_concat.fa > aligned_seq.fa
sed -i 's/:/_/' aligned_seq.fa
sed -i 's/:/_/' aligned_seq.fa
sed -i 's/,/_/' aligned_seq.fa
sed -i 's/(/_/' aligned_seq.fa
sed -i 's/)/_/' aligned_seq.fa
sed -i 's/_\{2,\}/_/g' aligned_seq.fa

trimal -fasta -in aligned_seq.fa -out trimmed_seq.fa

#Run IQTREE
iqtree -nt AUTO  -s trimmed_seq.fa
#rm pruned_tree.fa.treefile

#Alignment Run MAFFT EUK + ALL
cat concatenated_ready_seq.fa longhitsEuk.fa > concatenated_ready_seq.fa


mafft --auto concatenated_ready_seq.fa > aligned_seq.fa

#Trimming of Alignment Run Trimal*
trimal -fasta -in aligned_seq.fa -out trimmed_seq.fa

#Phylogeny - Run fasttree
FastTree -quiet trimmed_seq.fa > treefile 
