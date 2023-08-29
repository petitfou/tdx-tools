FROM ubuntu:23.10

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install --yes file

COPY ./setup /tmp/setup

WORKDIR /tmp/setup

RUN ./setup.sh