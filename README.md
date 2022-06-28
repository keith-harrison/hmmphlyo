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
dos2unix initialtree.sh
dos2unix prunetree.sh
```
* Running initialtree.sh (Gives phylogeny of the sequences given from two given PFAM alignments/HMMsearch results)
```bat
./initialtree.sh

```

* Running prunetree.sh (Gives refined phylogeny of pruned tree using manual pruned file from ITOL)
```bat
#NAME THE FILE pruneddraft.nwk and provide the concatenated_ready_seq.fa file
./prunetree.sh
```


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Do More Research on :
cut_ga (gathering threshold)
gappy out
