FROM python:3.7.4

LABEL maintainer="smurav@mail.ru"

RUN pip install pandas

COPY ./src/ /src/

WORKDIR /data/

ENTRYPOINT [ "python3", "/src/clinvar.py" ]

