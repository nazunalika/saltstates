{%- from "freeipa/map/map.jinja" import server with context %}
ipa_server_packages:
  pkg.installed:
    - names: {{ server.pkgs }}
    - refresh: True

