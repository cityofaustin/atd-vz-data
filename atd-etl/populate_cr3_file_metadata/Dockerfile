FROM python:3.10-slim

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y file

# Copy our own application
WORKDIR /app
COPY . /app

# Install requirements
RUN pip install -r requirements.txt
