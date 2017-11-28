{%- from "freeipa/map/map.jinja" import server, ipaservers with context %}

{# 
  If server, promote it to a replica. We don't need username password arguments since we are added
  to the ipaservers group, which is all that is mainly needed. The other switches are just there
  to mimic what we're doing on client and master installs.

  This state EXPECTS your host to have rDNS. If you do not, then it may fail. If you really don't
  care about rDNS, add --no-reverse (fyi, this isn't recommended).
#}

ipa_replica_install:
  cmd.run:
    - name: >
        ipa-replica-install
        {# Normal stuff here #}
        --no-ntp
        --ssh-trust-dns
        --unattend
        {# Conditional #}
        {%- if server.get('ca', true) %} --setup-ca{%- endif %}
        {%- if server.get('mkhomedir', True) %} --mkhomedir{%- endif %}
        {%- if server.get('dns', {}).get('enabled', True) %} --setup-dns{%- endif %}
        {%- if server.get('dns', {}).get('forwarders', []) %}
        {%- for forwarder in server.dns.forwarders %}
        --forwarder {{ forwarder }}
        {%- endfor %}
        {%- else %} 
        --no-forwarders
        {%- endif %}
    - creates: /etc/ipa/default.conf
    - require_in:
      - file: sssd_config

