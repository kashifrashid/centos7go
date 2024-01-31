# Using a more recent version of Node if compatible with your application
FROM node:16

# Install dependencies in one layer to reduce the number of layers
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    build-essential \
    libssl-dev \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    gettext \
 && rm -rf /var/lib/apt/lists/*

# Download and install Packer and Terraform in one layer
RUN mkdir -p /root/packer && cd /root/packer \
 && wget -q https://releases.hashicorp.com/packer/1.1.3/packer_1.1.3_linux_amd64.zip \
 && wget -q https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip \
 && unzip packer_1.1.3_linux_amd64.zip -d /usr/local/bin \
 && unzip terraform_0.11.1_linux_amd64.zip -d /usr/local/bin \
 && rm packer_1.1.3_linux_amd64.zip terraform_0.11.1_linux_amd64.zip

# Download and install Git in one layer
RUN mkdir -p /root/git && cd /root/git \
 && wget -q https://github.com/git/git/archive/v2.9.5.zip -O git.zip \
 && unzip git.zip \
 && cd git-2.9.5 \
 && make configure \
 && ./configure --prefix=/usr \
 && make all \
 && make install \
 && cd .. && rm -rf git-2.9.5 git.zip

# Set the working directory
WORKDIR /root/git
