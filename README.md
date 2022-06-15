# HMMPhylo
HMMPhylo is a library/docker container for taking the results of HMMsearch and creating phylogenetic trees from them.
This is used to study PPK protein sequences in Eukaryotes and other kingdoms.
## Tools Used
* Delbian (Standard Linux Image)
* Python is used to webscrape all the uniprot IDs used in the results of the HMMsearch
* MAFFT (MSA) 
* TrimAL 
* IQ-TREE

### Local Machine

Prerequisites

Before you continue, ensure you have met the following requirements:
* You have installed [Docker](https://docs.docker.com/get-docker/) for your operating system.
* If you are on windows then you will also need [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
* Setting up the System
```bat
git clone https://github.com/keith-harrison/hmmphylo/
cd hmmphylo
docker-compose up -d
docker-compose run --rm hmmphylo
dos2unix GO.sh
```
* Running GO.sh (Gives phylogeny of the sequences given)
```bat
./GO.sh
#Then input is the name of the file (this file is the results of the hmmsearch in fasta output)
```
* Running GOfull.sh (Gives phylogeny of full protein sequences given ids)
This will return the full protein sequences not just the snippets given in the hmm results for GO.sh
```bat
./GOfull.sh
#The input is the name of the file we wish to take uniprot ids from (this can take any file with format >ID1 >ID2 >....)
#For simplicity you can give the same input as the previous GO.sh and the second input will be "full<FILENAME>"
```
* Running newick.sh (Allows pruning of newick tree file alongside using the concatenated_ready_seq.fa file to generate a more refined tree using IQTREE)
On ITOL (online newick tree file viewer) prune the tree/results from previous GOfull analysis and put both this prunedtree.nwk and concatenated_ready_seq.fa from before and put it back into the work folder and run newick.sh.
```bat
./newick.sh
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Do More Research on :
cut_ga (gathering threshold)
gappy out
