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
```bat
git clone https://github.com/keith-harrison/hmmphlyo/
cd hmmphylo
docker-compose up -d
docker-compose run --rm hmmphylo
dos2unix GO.sh
#Have your file downloaded and with an apprioprate name as this will be the name of the folder :)
./GO.sh
#When an input is asked for put the entire filename including the file format THIS PART IS STILL UNDER DEVELOPMENT
./GOMultiple.sh 
#For this, which takes in multiple sequences you want to concatenate from different files 
#The input is the prefix of the file e.g for testfile1.fa testfile2.fa the input should be testfile
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Do More Research on :
cut_ga (gathering threshold)
gappy out