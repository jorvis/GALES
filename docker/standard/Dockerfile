FROM ubuntu:latest
MAINTAINER Joshua Orvis <jorvis@gmail.com>

#####
# Install a few needed utilities
RUN apt-get -y update && apt-get install -y --no-install-recommends git wget libmldbm-perl python3 python3-yaml python3-setuptools python3-pip sqlite3 zlib1g-dev libxml2-dev build-essential

RUN pip3 install --upgrade pip
RUN pip3 install biocode:0.9.0

#####
# Install Prodigal
RUN wget https://github.com/hyattpd/Prodigal/releases/download/v2.6.3/prodigal.linux
RUN mv prodigal.linux /usr/bin/prodigal
RUN chmod +x /usr/bin/prodigal

#####
# Install Barrnap
RUN wget -O barrnap-0.7.tar.gz https://github.com/tseemann/barrnap/archive/0.7.tar.gz
RUN tar -xzf barrnap-0.7.tar.gz
RUN mv barrnap-0.7 /opt/barrnap
ENV PATH $PATH:/opt/barrnap/bin

#####
# Install RAPSearch2
#RUN wget -O RAPSearch2.23_64bits.tar.gz https://sourceforge.net/projects/rapsearch2/files/RAPSearch2.23_64bits.tar.gz/download
RUN wget -O /usr/bin/prerapsearch https://www.dropbox.com/s/bwvpxbcpgw5cqg7/prerapsearch?dl=0
RUN chmod +x /usr/bin/prerapsearch
RUN wget -O /usr/bin/rapsearch https://www.dropbox.com/s/1tae3el38o6yfy3/rapsearch?dl=0
RUN chmod +x /usr/bin/rapsearch

#####
# Install TMHMM
RUN wget -O TMHMM-2.0c.tar.gz https://www.dropbox.com/s/h4ko8t5wtaliapu/TMHMM-2.0c.tar.gz?dl=0
RUN tar -xzf TMHMM-2.0c.tar.gz
RUN mv TMHMM-2.0c /opt/
ENV PATH $PATH:/opt/TMHMM-2.0c/bin

#####
# Install ARAGORN
RUN wget -O /usr/bin/aragorn https://www.dropbox.com/s/a207vip5d4gullk/aragorn?dl=0
RUN chmod +x /usr/bin/aragorn

## this if we want to compile ARAGORN, but I don't want to add the gcc dependency
#RUN wget -O aragorn1.2.38.tgz http://mbio-serv2.mbioekol.lu.se/ARAGORN/Downloads/aragorn1.2.38.tgz
#RUN tar -xzf aragorn1.2.38.tgz
#RUN mv aragorn1.2.38 /opt/
#RUN gcc -O3 -ffast-math -finline-functions -o /opt/aragorn1.2.38/aragorn /opt/aragorn1.2.38/aragorn1.2.38.c
#ENV PATH $PATH:/opt/aragorn1.2.38

#####
# Install HMMer3
# Investigate hmmpgmd
#  Article:  https://cryptogenomicon.org/2011/05/27/hmmscan-vs-hmmsearch-speed-the-numerology/
RUN wget http://eddylab.org/software/hmmer/hmmer.tar.gz
# Every RUN creates a new commit and AUFS layer
RUN tar -xzf hmmer.tar.gz && cd hmmer* && ./configure --prefix=/opt/hmmer-3.2.1 && make && make install
RUN ln -s /opt/hmmer-3.2.1/bin/* /usr/bin/

#####
# Install Attributor
RUN git clone https://github.com/jorvis/Attributor.git /opt/attributor
RUN ln -s /opt/attributor/attributor /usr/bin/

#####
# Stage data
RUN mkdir dbs


