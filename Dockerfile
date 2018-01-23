FROM ubuntu:16.04

LABEL maintainer="Kiwee <mael.razavet@gmail.com>"

USER root

RUN apt-get update \
    && apt-get install --no-install-recommends -y openjdk-8-jre-headless ca-certificates-java \
    && apt-get install -y wget python-pip build-essential \
    && apt-get -y autoremove \
    && apt-get -y clean  \
    && rm -rf /var/lib/apt/lists/*

# copy across pip files
COPY requirements.txt /requirements.txt

RUN pip install pip -U \
    && pip install -r /requirements.txt \
    && pip install jupyter_contrib_nbextensions \
    && rm -r /root/.cache/pip

# Spark dependencies
ENV APACHE_SPARK_VERSION 2.2.0
ENV HADOOP_VERSION 2.7

RUN cd /tmp && \
        wget -q http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
        echo "7a186a2a007b2dfd880571f7214a7d329c972510a460a8bdbef9f7f2a891019343c020f74b496a61e5aa42bc9e9a79cc99defe5cb3bf8b6f49c07e01b259bc6b *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha512sum -c - && \
        tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /usr/local && \
        rm spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark

ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

EXPOSE 8888

CMD ["jupyter", "notebook", "--no-browser", "--notebook-dir=/opt/notebooks", "--allow-root", "--ip", "0.0.0.0"]
