{%- from "freeipa/map/map.jinja" import server with context %}

krb5_config_server:
  file.managed:
    - name: {{ server.krb5conf }}
    - template: jinja
    - source: salt://freeipa/files/ipa-krb5.conf

