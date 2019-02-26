reset-gitea:
  cmd.run:
    - name: 'rm -rf /var/lib/gitea/*'
  file.managed:
    - name: /etc/gitea.ini
    - source: salt://gitea.ini
    - user: gitea
    - group: gitea
    - replace: True
  service.running:
    - name: gitea
    - watch:
      - cmd: reset-gitea

reset-gitea-repos:
  cmd.run:
    - name: 'rm -rf /home/gitea/*'
