{%- from "freeipa/map/map.jinja" import client, ipahost, ipaservers with context %}
testing:
  cmd.run:
    - name: echo "{{ client.clientsls }} {{ client.server }} {{ client.realm }} {{ client.domain }}"
