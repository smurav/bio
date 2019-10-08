FROM anapsix/alpine-java:8

ENV package_version 4.4

ADD https://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip /opt

RUN cd /opt/ \
         && unzip snpEff_latest_core.zip \
         && rm snpEff_latest_core.zip

ENTRYPOINT ["java", "-jar", "/opt/snpEff/SnpSift.jar"]
