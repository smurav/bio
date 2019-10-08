FROM anapsix/alpine-java:8

ENV package_version 4.4

ADD http://sourceforge.net/projects/snpeff/files/snpEff_latest_core.zip /app

RUN cd /app/ \
         && unzip snpEff_latest_core.zip \
         && rm snpEff_latest_core.zip

ENTRYPOINT ["java", "-jar", "/app/snpEff/SnpSift.jar"]
