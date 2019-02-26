docker:
  pkgrepo.managed:
    - name: deb https://download.docker.com/linux/debian stretch stable
    - key_url: https://download.docker.com/linux/debian/gpg
  pkg.installed:
    - name: docker-ce
    - require:
        - pkgrepo: docker
  service.running:
    - name: docker
    - enable: True
    - require:
        - pkg: docker
  # so we're not waiting for docker pull in jobs
  cmd.run:
    - name: 'docker pull composer && docker pull php:7.2-cli && docker pull composer/satis'


java:
  pkg.installed:
    - name: openjdk-8-jre

jenkins:
  pkgrepo.managed:
    - name: deb http://pkg.jenkins.io/debian-stable binary/
    - key_url: http://pkg.jenkins.io/debian-stable/jenkins.io.key
  pkg.latest:
    - name: jenkins
    - require:
      - pkg: java
      - pkgrepo: jenkins
  service.running:
    - name: jenkins
    - enable: True
    - require:
      - pkg: jenkins
  user.present:
    - require:
      - pkg: jenkins
    - name: jenkins
    - groups:
      - jenkins
      - docker
    - watch_in:
      - service: jenkins

gitea:
  file.managed:
    - name: /usr/bin/gitea
    - source: https://dl.gitea.io/gitea/1.4.3/gitea-1.4.3-linux-amd64
    - source_hash: https://dl.gitea.io/gitea/1.4.3/gitea-1.4.3-linux-amd64.sha256
    - mode: 0755
  user.present:
    - name: gitea
  group.present:
    - name: gitea

gitea_directory:
  file.directory:
    - name: /var/lib/gitea
    - user: gitea
    - group: gitea

gitea_config:
  file.managed:
    - name: /etc/gitea.ini
    - source: salt://gitea.ini
    - user: gitea
    - group: gitea
    - replace: False

gitea_service:
  file.managed:
    - name: /etc/systemd/system/gitea.service
    - source: salt://gitea.service
    - user: root
    - group: root
  service.running:
    - name: gitea
    - enable: True
    - require:
      - file: gitea
      - file: gitea_config
      - file: gitea_service
    - watch:
      - file: gitea_service

nginx:
  pkg.installed:
    - name: nginx
  file.managed:
    - name: /var/www/html/index.html
    - source: salt://nginx-menu.html

# dirty hack so jenkins can write satis files to web directory
nginx_dir:
  file.directory:
    - name: /var/www/html
    - user: jenkins
    - group: www-data

/etc/resolve.conf:
  file.managed:
    - source: salt://resolve.conf
