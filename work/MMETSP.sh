#Download MMETSP
wget https://zenodo.org/record/3247846/files/mmetsp_dib_trinity2.2.0_pep_zenodo.tar.gz
tar -xvf mmetsp_dib_trinity2.2.0_pep_zenodo.tar.gz
#MMETSP Clustered UniRef90 BIG
wget wwwuser.gwdg.de/~compbiol/metaeuk/2020_TAX_DB/MMETSP_zenodo_3247846_uniclust90_2018_08_seed_valid_taxids.tar.gz
tar -xvf MMETSP_zenodo_3247846_uniclust90_2018_08_seed_valid_taxids.tar.gz
#Download TARA
wget wwwuser.gwdg.de/~compbiol/metaeuk/2019_11/MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas.gz
tar -xvf MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas.gz
#Download ALL protein clusters BIG
wget wwwuser.gwdg.de/~compbiol/metaeuk/2019_11/MERC_MMETSP_Uniclust50_profiles.tar.gz
tar -xvf MERC_MMETSP_Uniclust50_profiles.tar.gz

#Build hmmprofile from trimmed_seq.fa OR use PP_kinase2.hmm
hmmbuild PP_kinase_all.hmm trimmed_seq.fa
#Run hmmsearch of file against hmm profile
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A myhits.sto PP_kinase_all.hmm MMETSP.pep &
#Move results back to home directory in order to use esl tools (not available on isca)
esl-reformat fasta myhits.sto > hits.fa

#join onto concatenated_ready_seq.fa OR just onto eukaryote_ppk_seq.fa
cat hits.fa concatenated_ready_seq.fa > hits_concat.fa

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

