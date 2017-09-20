FROM ubuntu:latest
MAINTAINER Joshua Orvis <jorvis@gmail.com>

#####
# Install a few needed utilities
RUN apt-get -y update && apt-get install -y --no-install-recommends git wget libmldbm-perl pandoc python3 python3-yaml python3-setuptools python3-pip sqlite3

RUN pip3 install --upgrade pip
RUN pip3 install pypandoc
RUN pip3 install biocode

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
# Install HMMer3
# Investigate hmmpgmd
#  Article:  https://cryptogenomicon.org/2011/05/27/hmmscan-vs-hmmsearch-speed-the-numerology/
# hmmscan --acc --cut_ga --cpu 4 -o ../workflows/prodigal.annotation.faa.part1.hmm.raw ~/Dropbox/igs/databases/coding_hmm.lib.bin ../workflows/prodigal.annotation.faa.part1
RUN wget http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2-linux-intel-x86_64.tar.gz
RUN tar -xzf hmmer-3.1b2-linux-intel-x86_64.tar.gz
RUN cp hmmer-3.1b2-linux-intel-x86_64/binaries/* /usr/bin/
RUN rm -rf hmmer-3.1b2-linux-intel-x86_64

#####
# Install Attributor
RUN git clone https://github.com/jorvis/Attributor.git /opt/attributor
RUN ln -s /opt/attributor/attributor /usr/bin/

#####
# Stage data
RUN mkdir dbs
#COPY ./uniprot_sprot.rapsearch2.db dbs/uniprot_sprot.rapsearch2.db
#COPY ./uniprot_sprot.rapsearch2.db.info dbs/uniprot_sprot.rapsearch2.db.info
#COPY ./bacteria_uniref.rapsearch2.db dbs/
#COPY ./bacteria_uniref.rapsearch2.db.info dbs/
#COPY ./uniprot_sprot.sqlite3 dbs/
#COPY ./coding_hmm.lib.bin.h3* dbs/
#COPY ./coding_hmm.lib.db dbs/
#COPY custom_TIGRFAMs_HMM.LIB.h* dbs/
#COPY ./coding_hmm_lib.sqlite3 dbs/
#COPY ./write_attributor_config.py /opt/bin/write_attributor_config.py
#COPY ./write_attributor_config.template.yaml /opt/bin/write_attributor_config.template.yaml

