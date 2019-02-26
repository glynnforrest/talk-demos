Vagrant.configure(2) do |config|
  config.vm.box = "debian/jessie64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "512"
  end

  config.vm.define "master" do |master|
    master.vm.network "private_network", ip: "192.168.4.2"
    master.vm.hostname = 'super-saltstack-master'

    master.vm.synced_folder "salt", "/srv/salt", :nfs => true
    master.vm.synced_folder "reactor", "/srv/reactor", :nfs => true

    master.vm.provision :salt do |salt|
      salt.install_type = "stable"
      salt.install_master = true
      salt.verbose = true
      salt.log_level = "info"
      salt.colorize = true
      salt.bootstrap_options = '-c /tmp'
      salt.run_highstate = false
      salt.minion_config = 'minion/master'
      salt.master_config = 'master'
    end
  end

  config.vm.define "web" do |web|
    web.vm.network "private_network", ip: "192.168.4.3"
    web.vm.hostname = 'super-saltstack-web'

    web.vm.provision :salt do |salt|
      salt.install_type = "stable"
      salt.install_master = false
      salt.verbose = true
      salt.log_level = "info"
      salt.colorize = true
      salt.bootstrap_options = '-c /tmp'
      salt.run_highstate = false
      salt.minion_config = 'minion/web'
    end
  end
end
