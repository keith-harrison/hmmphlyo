# HMMPhylo
HMMPhylo is a library/docker container for taking the results of HMMsearch and creating phylogenetic trees from them.
## Tools Used
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
git clone https://github.com/keith-harrison/FINDER/
cd Docker
docker-compose up 
docker-compose run --rm hmmphylo
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
