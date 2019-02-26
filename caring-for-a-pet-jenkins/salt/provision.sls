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

java:
  pkg.installed:
    - name: openjdk-8-jre

jenkins:
  pkgrepo.managed:
    - name: deb http://pkg.jenkins.io/debian-stable binary/
    - key_url: http://pkg.jenkins.io/debian-stable/jenkins.io.key
  pkg.installed:
    - name: jenkins
    - require:
      - pkg: java
      - pkgrepo: jenkins
  file.managed:
    - name: /var/lib/jenkins/init.groovy
    - source: salt://init.groovy
    - watch_in:
      - service: jenkins_service
  user.present:
    - require:
      - pkg: jenkins
    - name: jenkins
    - groups:
      - jenkins
      - docker
    - watch_in:
      - service: jenkins_service

jenkins_service:
  file.line:
    - name: /etc/default/jenkins
    - content: 'JAVA_ARGS="-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"'
    - match: ^JAVA_ARGS
    - mode: replace
    - watch_in:
      - service: jenkins_service
  service.running:
    - name: jenkins
    - enable: True
    - require:
      - file: jenkins
      - file: jenkins_service
      - pkg: jenkins

{% set nomad_sha = '88b6720082a85fed9d2e1729292056fa2567520a' %}
{% set nomad_src = 'https://releases.hashicorp.com/nomad/0.8.4/nomad_0.8.4_linux_amd64.zip' %}
nomad:
  archive.extracted:
    - name: /tmp/nomad
    - enforce_toplevel: False
    - source: {{nomad_src}}
    - source_hash: {{nomad_sha}}
    - unless: which nomad
  file.managed:
    - name: /usr/bin/nomad
    - source: /tmp/nomad/nomad
    - mode: 0755
    - unless: which nomad
    - require:
      - archive: nomad

nomad_config:
  file.managed:
    - name: /etc/nomad/nomad.hcl
    - source: salt://nomad.hcl
    - user: root
    - group: root
    - makedirs: True

nomad_service:
  file.managed:
    - name: /etc/systemd/system/nomad.service
    - source: salt://nomad.service
    - user: root
    - group: root
  service.running:
    - name: nomad
    - enable: True
    - require:
      - file: nomad
      - file: nomad_config
      - file: nomad_service
    - watch:
      - file: nomad_service
      - file: nomad_config

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


/etc/resolve.conf:
  file.managed:
    - source: salt://resolve.conf
