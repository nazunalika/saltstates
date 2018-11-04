ssh:
  pkg.installed:
    - pkgs:
      - openssh-server
      - openssh-clients

sshd:
  service.running:
    - name: sshd
    - enable: True
    - watch:
      - file: sshd
      - file: banner
    - require:
      - pkg: ssh
      - file: sshd
      - file: banner

  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://linux/ssh/files/{{ grains['osmajorrelease'] }}-sshd_config
    - user: root
    - group: root
    - mode: 600
    - template: jinja

banner:
  file.managed:
    - name: /etc/banner
    - source: salt://linux/ssh/files/banner
    - mode: 644
    - user: root
    - group: root

