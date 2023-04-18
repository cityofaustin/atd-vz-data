#
# ATD Vision Zero Processor
# An ETL Processor that uses Python 3.8, Splinter, Selenium and Chrome/ChromeDriver
#
FROM python:3.8-alpine3.10

RUN mkdir /app && mkdir /app/tmp && mkdir /data

RUN apk add bash build-base python3-dev libffi-dev openssl-dev \
    chromium chromium-chromedriver p7zip

# the following is helpful when developing using this image but is not needed for a production build
#RUN apk update && apk add build-base python3-dev libffi-dev openssl-dev && pip3 install magic-wormhole

COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt

WORKDIR /app

COPY app /app

EXPOSE 5555/tcp

CMD ["bash"]
