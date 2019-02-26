nginx:
    pkg.installed:
        - name: nginx
    service.running:
        - name: nginx
        - require:
            - pkg: nginx

web_document:
    file.managed:
        - name: /var/www/html/index.html
        - source: salt://nginx/index.html.j2
        - template: jinja
