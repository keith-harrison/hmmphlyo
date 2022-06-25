#take fullPPK.fa (results of search with Gofull.py ran on it)

sed -i '/^<!DOCTYPE/d' fullPPK.fa
grep -e ">" fullPPK.fa > UniprotIDs.txt && sed -i 's/>//g' Uniprot.txt
#Webscrape Ids
run python NewickTaxa.py

sed -i 's/^/>/g' taxas.txt
seqkit rmdup -n taxas.txt -o Taxa.txt -d deletedTaxa.fa
sed -i -r '/^\s*$/d' Taxa.txt
sed -i 's/>//g' Taxa.txt

#IDS READY
#WANT NAMES FROM trimmed_seq.fa
#These IDs should be in the same order as originalnames.txt
grep -e ">" trimmed_seq.fa > names.txt
sed -i 's/>//' names.txt

#go through treefile and find position in names and switch contents with the position in 
run python AlterNewick.py
#Synechococcus_sp._strain_JA-2-3B&#039;a manual change to 321332
#Mycolicibacterium_smegmatis_strain_ATCC_700084_/_mc(2_155) to 246196
#Streptomyces_coelicolor_strain_ATCC_BAA-471_/_A3(2_/_M145) to 100226
#Synechococcus_sp._strain_ATCC_27167_/_PCC_6312_ to 195253
#Nostoc_sp._&#039 to 1177