init_umask:
  file.append:
    - name: /etc/sysconfig/init
    - text:
      - umask 027
