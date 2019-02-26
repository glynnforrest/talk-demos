# reset the web minion
sudo salt super-saltstack-web state.sls reset

# disconnect all minions
sudo salt-key -D --yes

# reset motd.txt
echo '' > /home/vagrant/motd.txt
