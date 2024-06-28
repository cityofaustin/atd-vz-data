# Use the latest Ubuntu image
FROM ubuntu:latest

# Install Python to use the requirements file
RUN apt-get update && apt-get install -y python3-pip aptitude pgloader postgresql postgresql-client vim htop

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt /app/

# Install Python dependencies globally
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt 

# Start bash when the container launches
CMD ["bash"]
