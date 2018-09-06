
    yum install -y epel-release 
    yum update -y
     yum install -y wget unzip git
    curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
    python get-pip.py
    pip install awscli
    pip install ansible
    wget https://releases.hashicorp.com/packer/1.1.3/packer_1.1.3_linux_amd64.zip
    wget https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip
    unzip packer_1.1.3_linux_amd64.zip
    unzip terraform_0.11.1_linux_amd64.zip
    mv packer /usr/local/bin/packer
    mv terraform /usr/local/bin/terraform
    rm *.zip
    echo "10.0.0.30  db.local" >> /etc/hosts 
