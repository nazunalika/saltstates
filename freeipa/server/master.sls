{%- from "freeipa/map/map.jinja" import server with context %}

{#
  This is where the installation of the first master occurs. This is a bit tricky and can
  result in some odd behavior or even failure. Here are some things to keep in mind here:

    * Make sure the hostname is set properly in /etc/hostname and /etc/hosts.
    * Your IP should be static
    * If you are delegated a subdomain (ipa.domain.tld), this should just work if it's
      properly delegated. If not, --no-host-dns should push the deployment through.
    * If you are using a top level domain (no delegation), don't list forwarders, unless
      it is absolutely required. It's better you let it set to --no-forwarders if you have
      no other internal DNS servers.

  Other than that, this should just "work" without much of a fuss.
#}
{%- if server.enabled %}

include:
  - freeipa.server.packages

/etc/sysconfig/dirsrv.systemd:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - contents: |
        [Service]
        # uncomment this line to raise the file descriptor limit
        # LimitNOFILE=8192
        LimitNOFILE=16384

freeipa_server_install:
  cmd.run:
    - name: >
        ipa-server-install
        --realm {{ server.realm }}
        --domain {{ server.domain }}
        --hostname {% if server.hostname is defined %}{{ server.hostname }}{% else %}{{ grains['fqdn'] }}{% endif %}
        --ds-password {{ server.ldap.password }}
        --admin-password {{ server.admin.password }}
        --ssh-trust-dns
        {%- if not server.get('ntp', {}).get('enabled', True) %} --no-ntp{%- endif %}
        {%- if server.get('dns', {}).get('enabled', True) %} --setup-dns{%- endif %}
        {%- if server.get('dns', {}).get('forwarders', []) %}
        {%- for forwarder in server.dns.forwarders %} 
        --forwarder={{ forwarder }}
        {%- endfor %}
        {%- else %} 
        --no-forwarders
        {%- endif %}
        {%- if server.get('mkhomedir', True) %} --mkhomedir{%- endif %}
        --auto-reverse
        --no-host-dns
        --unattended
    - creates: /etc/ipa/default.conf
    - require:
      - pkg: ipa_server_packages
      - file: /etc/sysconfig/dirsrv.systemd
    - require_in:
      - service: sssd_config

{%- endif %}
