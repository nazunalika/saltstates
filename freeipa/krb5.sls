{#
  TODO: Make this OS agnostic.
#}

{%- from "freeipa/map/map.jinja" import client with context %}

krb5_conf:
  file.managed:
    - name: {{ client.krb5conf }}
    - mode: 644
    - user: root
    - group: root
{%- if grains['role'] is defined and grains['role'] == 'freeipa' %}
    - source: salt://freeipa/files/ipa-krb5.conf
    - template: jinja
{%- else %}
    - source: {{ client.krb5src }}
    - template: jinja
{%- endif %}
