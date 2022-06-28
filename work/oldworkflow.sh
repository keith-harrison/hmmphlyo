#Go on Pfam and grab the areas of an  interesting protein sequence we want to look at 
#https://pfam.xfam.org

#We are using the start and end domains of PPK (in order to just get the parts of the sequence we want)
#This python file will make the fasta single lined, have the fasta headers according to their taxonomy and have the
#full sequence using the locations of the domains.
python fixFile.py 
find . -maxdepth 1 -name "full.fasta" -exec sed -i '/^<!DOCTYPE/d' {} \;
find . -maxdepth 1 -name "full.fasta" -exec seqkit rmdup -n {} -o concatenated_ready_seq.fa -d deleted.fa\;

#4. Run phylogeny (Mafft,Trimal,FastTree)
mafft --auto concatenated_ready_seq.fa > aligned_seq.fa # no methods applicable as a large number of sequences
trimal  -fasta -in aligned_seq.fa -out trimmed_seq.fa #ruins results -gappyout
FastTree -quiet trimmed_seq.fa > newtreefile #dont want to use psuedo as there is a high similarity / wag bad

---------------------------------------------------------------------------------------------------------------



#6.5 Add reference proteomes ppk sequences to this pruned tree. Do this by using original fasta
#So Download MMETSP
wget https://zenodo.org/record/3247846/files/mmetsp_dib_trinity2.2.0_pep_zenodo.tar.gz
tar -xvf mmetsp_dib_trinity2.2.0_pep_zenodo.tar.gz
#go into pep and rename MMETSP files
for filename in *.pep; do
  newFilename=$(sed 's/trinity_out_2.2.*.Trinity.fasta.transdecoder.//g' <<< "$filename")
  mv "$filename" "$newFilename"
done
#Put filename in each fastaheading
for f in *.faa; do sed -i "s/^>/>${f%.faa}/g" "${f}"; done

#Do HMMSEARCH on these files
#Return Best result from each File

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

#10 Run phylogeny properly with these hits
#Mafft Add does some weird stuff with the names, so we need to fix them
#fixing Matou and MGT files

sed -i 's/>*.*|/>/' aligned_matou.fasta 
sed -i 's/>*.*|/>/' aligned_mgt.fasta
#>9ins:113K-114N,etc|MATOU-v1_24803117_2_464262_PF02503_PF13090
#>7ins:1L-237E,etc|MGT_3623192_1_MGT-v1-319_54324592
trimal -fasta -in aligned_matou.fasta -out aligned_matou.fasta
trimal -fasta -in aligned_mgt.fasta -out aligned_mgt.fasta
iqtree -nt AUTO -s aligned_matou.fasta -m LG+R6 -pre aligned_matou
iqtree -nt AUTO -s aligned_mgt.fasta -m LG+R6 -pre aligned_mgt

#11 Add taxonomies to the initial tree
#take fullPPK.fa (results of search with Gofull.py ran on it)
sed -i '/^<!DOCTYPE/d' fullPPK.fa
grep -e ">" fullPPK.fa > UniprotIDs.txt && sed -i 's/>//g' Uniprot.txt
#Webscrape Ids
python NewickTaxa.py
sed -i 's/^/>/g' taxas.txt
seqkit rmdup -n taxas.txt -o Taxa.txt -d deletedTaxa.fa
sed -i -r '/^\s*$/d' Taxa.txt
sed -i 's/>//g' Taxa.txt
#IDS READY
#Get names used in the original tree
grep -e ">" trimmed_seq.fa > names.txt
sed -i 's/>//' names.txt
python AlterNewick.py
#Synechococcus_sp._strain_JA-2-3B&#039;a manual change to 321332
#Mycolicibacterium_smegmatis_strain_ATCC_700084_/_mc(2_155) to 246196
#Streptomyces_coelicolor_strain_ATCC_BAA-471_/_A3(2_/_M145) to 100226
#Synechococcus_sp._strain_ATCC_27167_/_PCC_6312_ to 195253
#Nostoc_sp._&#039 to 1177