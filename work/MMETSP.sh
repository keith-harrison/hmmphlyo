#Build hmmprofile from concatenated_ready_seq.fa OR use PP_kinase2.hmm
#Run hmmsearch of file against hmm profile
hmmsearch --tblout $1.tblout $1.hmm $1.fa
hmmsearch -E 1 --domE 1 --incE 0.01 --incdomE 0.03 --seqdb uniprotrefprot 