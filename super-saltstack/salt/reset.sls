# reset the web minion, but not enought to require an internet connection
nginx_stopped:
    service.dead:
        - name: nginx
        - enable: False

remove_files:
    file.absent:
        - names:
            - /var/www/html/index.html
            - /var/www/html/super-saltstack.jpg
            - /tmp/motd.txt
