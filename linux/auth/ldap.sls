{#
  This state should only be used in combination with freeipa. It should not be 
  referenced in linux.auth at all. Doing so will only be problematic. LDAP
  should only be configured after a successful client/replica installation,
  which will inevitably replace the ldap.conf that is generated at IPA init.

  In the event a new replica is added, it is recommended to run this state along
  all RHEL systems.
#}

{%- from "freeipa/map/map.jinja" import client, server with context %}

ldap_config:
  file.managed:
    - name: {{ client.ldapconf }}
    - user: root
    - group: root
    - mode: 644
    - source: salt://linux/auth/files/ldap/ipa-ldap.conf
    - template: jinja

ldap_certificate:
  file.managed:
    - name: /etc/openldap/cacerts/ipa.crt
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - source: salt://freeipa/files/ipa.crt

ldap_cert_rehash:
  cmd.run:
    - name: /usr/sbin/cacertdir_rehash /etc/openldap/cacerts

{#
  This is used for RHEL 5 systems as we are avoiding using sssd. When all legacy
  systems are gone, the below can be removed.
#}

{%- set os = 'rhel' ~ grains['osmajorrelease'] %}
{% if os == '5' %}
ldap_legacy:
  file.managed:
    - name: /etc/ldap.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://linux/auth/files/nss-ldap.conf
    - template: jinja

{% endif %}
