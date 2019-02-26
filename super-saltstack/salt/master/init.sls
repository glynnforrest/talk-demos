tmux:
    pkg.installed:
        - name: tmux
    file.managed:
        - source: salt://master/.tmux.conf
        - name: /home/vagrant/.tmux.conf

vim:
    pkg.installed

# required for the inotify beacon module
pyinotify:
    pkg.installed:
        - name: python-pyinotify

reset_script:
    file.managed:
        - source: salt://master/reset.sh
        - name: /home/vagrant/reset.sh
        - user: vagrant
        - mode: 0755

reset_all_script:
    file.managed:
        - source: salt://master/reset_all.sh
        - name: /home/vagrant/reset_all.sh
        - user: vagrant
        - mode: 0755

motd.txt:
    file.managed:
        - name: /home/vagrant/motd.txt
        - user: vagrant
        - mode: 0644
