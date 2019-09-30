ARG version=xenial

FROM ubuntu:${version}

LABEL maintainer="frank.foerster@ime.fraunhofer.de"
LABEL description="Dockerfile providing the HISAT2 mapping software"

#
# pin the version of all packages to the following versions
#

# wget to 1.17.1
RUN echo "Package: wget\nPin: version 1.17.1*\nPin-Priority: 1000" > /etc/apt/preferences.d/wget

# unzip to 6.0-20
RUN echo "Package: unzip\nPin: version 6.0-20*\nPin-Priority: 1000" > /etc/apt/preferences.d/unzip

# python to 2.7.11
RUN echo "Package: python\nPin: version 2.7.11*\nPin-Priority: 1000" > /etc/apt/preferences.d/python

# build-essential to 12.1
RUN echo "Package: build-essential\nPin: version 12.1*\nPin-Priority: 1000" > /etc/apt/preferences.d/build-essential

RUN apt-get update && apt-get -y install \
    wget \
    unzip \
    python \
    build-essential

WORKDIR /opt

RUN wget ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/downloads/hisat2-2.1.0-source.zip && unzip hisat2-2.1.0-source.zip && cd hisat2-2.1.0 && make && rm /opt/hisat2-2.1.0-source.zip

ENV PATH "$PATH:/opt/hisat2-2.1.0/"

VOLUME /data

WORKDIR /data

CMD hisat2 --help
