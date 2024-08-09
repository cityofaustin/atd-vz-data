FROM python:3.11-slim

WORKDIR /app
COPY . /app

RUN apt-get -y update
RUN chmod -R 755 /app/*
RUN pip install -r requirements.txt
