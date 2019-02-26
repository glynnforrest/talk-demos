reset-jenkins:
  cmd.run:
    - name: 'rm -rf /var/lib/jenkins/*'
  service.running:
    - name: jenkins
    - watch:
      - cmd: reset-jenkins
