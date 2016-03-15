# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty32"
  config.vm.network "forwarded_port", guest: 8000, host: 12345

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end

  config.vm.provision :shell, :path => "scripts/bootstrap.sh" 
  config.vm.provision :shell, :inline => 'echo "cd /vagrant;. .env;" >> /home/vagrant/.bashrc'
end
