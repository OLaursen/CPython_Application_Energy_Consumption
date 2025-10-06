FROM ubuntu:22.04

# Prevents some interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies: qemu for ARM emulation, unzip for packer, etc.
RUN apt-get update && apt-get install -y \
    wget curl unzip git xz-utils \
    qemu qemu-user-static \
    && rm -rf /var/lib/apt/lists/*

# Install HashiCorp Packer 
RUN PACKER_VERSION=1.11.2 && \
    wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    rm packer_${PACKER_VERSION}_linux_amd64.zip

# Install arm-image plugin for packer
RUN packer plugins install github.com/solo-io/arm-image

# Default workdir for mounting your project
WORKDIR /workspace

CMD [ "bash" ]
