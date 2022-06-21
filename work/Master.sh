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
cat MMETSP* > MMETSP.pep
rm mmetsp_dib_trinity2.2.0_pep_zenodo.tar.gz
#Download TARA
wget wwwuser.gwdg.de/~compbiol/metaeuk/2019_11/MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas.gz
gunzip MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas.gz
rm MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas.gz
#Build hmmprofiles for the 6000 sequences and the 43 in the refined tree
#grab trimmed_seq_all.fa from folder 4
hmmbuild PP_kinase_all.hmm trimmed_seq_all.fa 
#grab pruned_tre.fasta from folder 5
hmmbuild PP_kinase_refined.hmm trimmed_seq_refined.fa

#7.5 HMMSearch Tara and MMETSP
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A hitsMMETSPAll.sto PP_kinase_all.hmm MMETSP.pep &
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A hitsTaraAll.sto PP_kinase_all.hmm MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas &

nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A hitsMMETSPRefined.sto PP_kinase_refined.hmm MMETSP.pep &
nohup hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 -A hitsTaraRefined.sto PP_kinase_refined.hmm MetaEuk_preds_Tara_vs_euk_profiles_uniqs.fas &

esl-reformat fasta hitsMMETSPAll.sto > hitsMMETSPAll.fa
esl-reformat fasta hitsTaraAll.sto > hitsTaraAll.fa

esl-reformat fasta hitsMMETSPRefined.sto > hitsMMETSPRefined.fa
esl-reformat fasta hitsTaraRefined.sto > hitsTaraRefined.fa


#fix MMETSP hits 
python fixMMETSP.py
#fix Tara hits
sed -i 's/|[^|]*//2g' hitsTaraAll.fa
sed -i 's/|/_/g' hitsTaraAll.fa

sed -i 's/|[^|]*//2g' hitsTaraRefined.fa
sed -i 's/|/_/g' hitsTaraRefined.fa

#Remove sequences < 600 peptides #back on home machine
seqkit seq -m 600 hitsMMETSPAll.fa > hitsMMETSPAll_600.fa
seqkit seq -m 600 hitsTaraAll.fa > hitsTaraAll_600.fa
seqkit seq -m 600 hitsMMETSPRefined.fa >  hitsMMETSPRefined_600.fa
seqkit seq -m 600 hitsTaraRefined.fa > hitsTaraRefined_600.fa
cat hitsMMETSPAll_600.fa hitsTaraAll_600.fa  > hitsAll.fa
cat hitsMMETSPRefined_600.fa hitsTaraRefined_600.fa  > hitsRefined.fa

#Have these hits 
#8. Use Raxml EPA or PPLACER to place these significant hits on the IQ tree. / Actually use EPA-ng new tool from raxml, complete overhaul of raxml epa
#https://github.com/Pbdas/epa-ng

#DO THESE ONLINE
#https://mafft.cbrc.jp/alignment/server/add_sequences.html
mafft --add hitsMMETSPALL_600.fa pruned_tree.fast > aligned_MMETSPAll.fasta
mafft --add hitsTaraALL_600.fa pruned_tree.fast > aligned_TaraAll.fasta
mafft --add hitsMMETSPRefined_600.fa pruned_tree.fast > aligned_MMETSPRefined.fasta
mafft --add hitsTaraRefined_600.fa pruned_tree.fast > aligned_TaraRefined.fasta

#run Raxml EPA-NG(new one) #Look at IQTree file to decide on model parameter
epa-ng --tree iqtree.nwk --ref-msa pruned_tree.fasta --query aligned_MMETSPAll.fasta --outdir MMETSPAll --model LG+R6
epa-ng --tree iqtree.nwk --ref-msa pruned_tree.fasta --query aligned_TaraAll.fasta --outdir TaraAll --model LG+R6
epa-ng --tree iqtree.nwk --ref-msa pruned_tree.fasta --query aligned_MMETSPRefined.fasta --outdir MMETSPRefined --model LG+R6
epa-ng --tree iqtree.nwk --ref-msa pruned_tree.fasta --query aligned_TaraRefined.fasta --outdir TaraRefined --model LG+R6
#visualise trees in itol

#9. Run similar process on the Matou and MGT Tara Data
#Perform hmmsearch on geneatlas tara website to get results in faa format
#https://tara-oceans.mio.osupytheas.fr/ocean-gene-atlas/

#reformat results 
sed -i 's/,/_/g' matou.faa
sed -i 's/ /_/g' matou.faa
sed -i 's/,/_/g' mgt.faa
sed -i 's/ /_/g' mgt.faa
seqkit seq -m 600 matou.faa > matou.faa
seqkit seq -m 600 mgt.faa > mgt.faa
#use online Mafft ADD to place these hits on the IQ tree
mafft --add matou.faa pruned_tree.fast > aligned_matou.fasta #DO ONLINE THIS IS AN EXAMPLE CODE
#https://mafft.cbrc.jp/alignment/server/add_sequences.html

#run Raxml EPA-NG(new one) #Look at IQTree file to decide on model parameter
epa-ng --tree iqtree.nwk --ref-msa pruned_tree.fasta --query aligned_matou.fasta --outdir matou --model LG+R6
epa-ng --tree iqtree.nwk --ref-msa pruned_tree.fasta --query aligned_mgt.fasta --outdir mgt --model LG+R6

