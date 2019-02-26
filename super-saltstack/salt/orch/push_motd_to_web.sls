# copy the updated motd to the master
# this isn't strictly neccessary in our case, since the motd lives on
# the master
copy_motd_to_master:
    salt.function:
        - name: cp.push
        - tgt: 'super-saltstack-master'
        - arg:
            - '/home/vagrant/motd.txt'

push_motd_to_web:
    salt.function:
        - name: cp.get_file
        - tgt: 'super-saltstack-web'
        - arg:
            - 'salt://minionfs/super-saltstack-master/home/vagrant/motd.txt'
            - '/tmp/motd.txt'

# run highstate on the web minion, which will pick up the new motd
highstate_web:
    salt.state:
        - tgt: 'super-saltstack-web'
        - highstate: True
        - require:
            - copy_motd_to_master

# send a custom event when the highstate completes
notify_webserver_running:
    salt.function:
        - name: event.send
        - tgt: 'super-saltstack-web'
        - arg:
            - 'super-saltstack/webserver/up'
        - require:
            - highstate_web
