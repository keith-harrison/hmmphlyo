#FROM command installs the default ubuntu package 
FROM debian
RUN apt-get -qq update && apt-get -y upgrade && \
	apt install -y wget libfindbin-libs-perl software-properties-common unzip && \
    apt-get install -y software-properties-common build-essential && \
    apt-get install -y python3-pip python3-dev build-essential
RUN apt-get install dos2unix
RUN wget -q -O Miniconda3-latest-Linux-x86_64.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 
RUN  apt-get install -y mafft
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN conda install -c bioconda iqtree
RUN conda install -c bioconda seqkit
RUN conda install -c bioconda fasttree
RUN apt install -y git
RUN git clone https://github.com/inab/trimal && cd trimal/source && make && mv ./* /usr/bin
RUN rm -r trimal
RUN apt install nano
RUN pip install --upgrade numpy
RUN apt-get -y install autoconf

RUN  wget http://eddylab.org/software/hmmer/hmmer.tar.gz && tar zxf hmmer.tar.gz && cd hmmer-3.3.2 && ./configure && make && make install && cd easel && make && make install
RUN conda install -c bioconda epa-ng
RUN pip install taxonomy-ranks
RUN conda install -c bioconda taxonkit
RUN wget ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz && tar zxf taxdump.tar.gz && mkdir /root/.taxonkit && mv  *.dmp /root/.taxonkit
#RUN git clone https://github.com/EddyRivasLab/easel && cd easel && autoconf && ./configure && make && make install
RUN pip install --upgrade ete3
RUN pip install pandas
ENV PATH="${PATH}:/bin"
ENV PATH="${PATH}:/usr/bin"

#TrimAL