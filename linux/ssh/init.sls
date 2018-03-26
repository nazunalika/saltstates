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
    - user: root
    - group: root
    - mode: 600
    - contents_pillar: ssh:sshd_config

banner:
  file.managed:
    - name: /etc/banner
    - source: salt://linux/ssh/files/banner
    - mode: 644
    - user: root
    - group: root

