#Download MMETSP files
https://zenodo.org/record/3247846/files/mmetsp_dib_trinity2.2.0_pep_zenodo.tar.gz?download=1
#TAROU - not used 
https://www.genoscope.cns.fr/tara/
#Rename MMETSP files

for filename in *.pep; do
  newFilename=$(sed 's/trinity_out_2....Trinity.fasta.transdecoder.//g' <<< "$filename")
  mv "$filename" "$newFilename"
done

#Move all files to new concatenated taxon file.

#Find MMETSP information online
#https://www.evernote.com/shard/s40/client/snv?noteGuid=b9ad355f-b84f-4208-87bb-fa8758af0901&noteKey=5afaeee672d40e8045b9957f8a2132d8&sn=https%3A%2F%2Fwww.evernote.com%2Fshard%2Fs40%2Fsh%2Fb9ad355f-b84f-4208-87bb-fa8758af0901%2F5afaeee672d40e8045b9957f8a2132d8&title=Marine%2BMicrobial%2BEukaryote%2BTranscriptome%2BSequencing%2BProject%2BListing
#Join mmetsp file by taxon
python mmetsp.py

#Run hmmsearch for each file returning the fasta sequence for only the best hit
#download hmm to use or build your own
for filename in *.pep; do
  hmmsearch -A myhits.sto PP_kinase.hmm "$filename"
  #take top hit of myhits.sto*

  esl-reformat fasta myhits.sto > "$filename".fasta

#rename headers in the fasta file to just be the file name
for line in $(cat "$filename".fasta); do
    newLine=$(sed 's/^>/>"$filename"/g' <<< "$line")
  done > "$filename".fasta
done

#Concatenate all fasta files into one file
cat *.fasta > MMETSP.fasta

#Join MMETSP.fasta to the pruned concatenated fasta file
cat MMETSP.fasta newick_seq_line.fa > MMETSP_REF.fasta
mafft --auto MMETSP_REF.fasta > aligned_seq.fasta
trimal -fasta -gappyout -in aligned_seq.fasta -out trimmed_seq_gappy.fasta
nohup iqtree -nt AUTO -s trimmed_seq_gappy.fasta -bb 1000 -pre MMETSP_REF &
