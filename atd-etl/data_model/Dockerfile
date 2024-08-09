FROM python:3.11-slim

WORKDIR /app
COPY . /app

RUN apt-get -y update
# we need p7zip-full to extract CRIS zips
# poppler-utils as a pdf2image dependency to snip crash diagrams out of pdfs
RUN apt-get install -y p7zip-full poppler-utils
RUN chmod -R 755 /app/*
RUN chmod +x /app/cris_import.py
RUN pip install -r requirements.txt
