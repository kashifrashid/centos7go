# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  config.vm.box = "centos/7"
  
  config.vm.define "web" do |web|
    web.vm.network :private_network, ip: "10.0.0.10"
    web.vm.network "forwarded_port", guest: 80, host: 8080
    web.vm.hostname = 'webserver'
    web.vm.provision "shell", inline: <<-SHELL
      yum install -y epel-release
      yum update -y
      yum install -y httpd
      curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash -
      yum -y install nodejs
      yum install gcc-c++ make
      /bin/systemctl restart httpd.service
      echo "10.0.0.20  str.local" >> /etc/hosts 
    SHELL

  end 
  config.vm.define "str" do |str|
    str.vm.network :private_network, ip: "10.0.0.20"
    str.vm.hostname = 'strServer'
    # str.vm.provision "shell", inline: <<-SHELL
    #   yum install -y epel-release 
    #   yum update -y
    #   yum install -y wget unzip git
    #   curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
    #   python get-pip.py
    #   pip install awscli
    #   pip install ansible
    #   wget https://releases.hashicorp.com/packer/1.1.3/packer_1.1.3_linux_amd64.zip
    #   wget https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip
    #   unzip packer_1.1.3_linux_amd64.zip
    #   unzip terraform_0.11.1_linux_amd64.zip
    #   mv packer /usr/local/bin/packer
    #   mv terraform /usr/local/bin/terraform
    #   rm *.zip
    #   echo "10.0.0.30  db.local" >> /etc/hosts 
    # SHELL
    str.vm.provision "shell", path: "go_install.sh"
  end
  config.vm.define "db" do |db|
     db.vm.network :private_network, ip: "10.0.0.30"
     db.vm.hostname = 'dbserver'
     db.vm.provision "shell", inline: <<-SHELL
       yum install -y epel-release 
       yum update -y
       yum install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7.3-x86_64/pgdg-redhat10-10-2.noarch.rpm -y 
       yum -y install postgresql10 postgresql10-server postgresql10-contrib postgresql10-libs -y
       /usr/pgsql-10/bin/postgresql-10-setup initdb
       systemctl enable postgresql-10.service
       systemctl start postgresql-10.service
     SHELL
  end
  

  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
    vb.cpus =  4
    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end

# End of the FILE
end
