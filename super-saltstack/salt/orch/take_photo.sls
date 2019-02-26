# take a photo on the host minion
take_photo:
    salt.function:
        - name: cmd.run
        - tgt: 'super-saltstack-host'
        - arg:
            - 'imagesnap /tmp/super-saltstack.jpg'

# copy the new photo to the master
grab_photo:
    salt.function:
        - name: cp.push
        - tgt: 'super-saltstack-host'
        - arg:
            - '/tmp/super-saltstack.jpg'
        - require:
            - take_photo

# copy the new photo from the master to the web minion
push_photo:
    salt.function:
        - name: cp.get_file
        - tgt: 'super-saltstack-web'
        - arg:
            - 'salt://minionfs/super-saltstack-host/private/tmp/super-saltstack.jpg'
            - '/var/www/html/super-saltstack.jpg'
        - require:
            - grab_photo
