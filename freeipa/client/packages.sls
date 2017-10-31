{%- from "freeipa/map/map.jinja" import client with context %}
{#
  Necessary package installation for our RHEL/CentOS clients.
#}

ipa_client_packages:
  pkg.installed:
    - names: {{ client.pkgs }}
    - refresh: True
