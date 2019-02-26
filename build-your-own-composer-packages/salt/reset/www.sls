remove_satis:
  file.directory:
    - name: /var/www/html/pkg/
    - clean: True
    - user: jenkins
    - group: www-data
