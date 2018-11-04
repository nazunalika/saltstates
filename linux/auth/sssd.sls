{#
  This state should only be used in combination with freeipa. It should not be 
  referenced in linux.auth at all. Doing so will only be problematic. SSSD
  should only be configured after a successful client/replica installation.

  In the event a new replica is added, it is recommended to run this state along
  all RHEL 6 and RHEL 7 systems to update them as necessary. 
#}

{%- from "freeipa/map/map.jinja" import client,server with context %}

sssd_config:
  service.running:
    - name: sssd
    - enable: True
    - watch:
      - file: sssd_config

  file.managed:
    - name: {{ client.sssdconf }}
    - user: root
    - group: root
    - mode: 600
    - source: salt://linux/auth/files/sssd/ipa-sssd.conf
    - template: jinja
    - backup_mode: both
