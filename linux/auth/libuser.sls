include:
  - linux.auth.packages

libuser_conf:
  file.replace:
    - name: /etc/libuser.conf
    - pattern: ^crypt_style = .*
    - repl: crypt_style = sha512
    - append_if_not_found: False
    - require:
      - pkg: authentication_packages

