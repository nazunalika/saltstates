{%- from "freeipa/map/map.jinja" import client, ipahost, ipaservers with context %}
{% set os = 'rhel' ~ grains['osmajorrelease'] %}

{#
  RHEL/CentOS FreeIPA installation here. These are the steps we take:
    * Pull the service account keytab and kinit against it
    * Use `curl` for a JSON call against the IPA master to create the host
    * Optionally, if a replica, add it to the ipaservers group
    * Remove keytabs and cookies
    * Use ipa-client-install to finish enrollment
#}

include:
  - freeipa.keytab
  - freeipa.client.packages

{%- if client.install_principal is defined %}
{%- set otp = salt['random.get_str'](20) %}

ipa_service_principal:
  file.managed:
    - name: /tmp/service.keytab
    - source: {{ client.get("install_principal", {}).get("source", "salt://freeipa/files/service.keytab") }}
    - mode: 600
    - user: root
    - group: root
    - unless:
      - ipa-client-install --unattended 2>&1 | grep "already configured"

ipa_get_ticket:
  cmd.run:
    - name: kinit {{ client.get("install_principal", {}).get("principal_user", "admin") }}@{{ client.get("realm", "") }} -kt /tmp/service.keytab
    - require:
      - file: ipa_service_principal
    - onchanges:
      - file: ipa_service_principal

ipa_host_add:
  cmd.run:
    - name: >
        curl -k -s
        -H referer:https://{{ ipaservers[0] }}/ipa
        --negotiate -u :
        -H "Content-Type:application/json"
        -H "Accept:applicaton/json"
        -c /tmp/cookiejar -b /tmp/cookiejar
        -X POST
        -d '{
          "id": 0,
          "method": "host_add",
                    "params": [
            [
              "{{ client.get("hostname", {})  }}"
            ],
            {
              "all": false,
              "force": false,
              "no_members": false,
              {%- if client.dns.delegated %}
              "no_reverse": true,
              {%- else %}
              "no_reverse": false,
              {%- endif %}
              "random": false,
              "raw": true,
              {%- if pillar.freeipa.server is defined %}
              "ip_address": "{{ salt['grains.get']('fqdn_ip4')[0] }}",
              {%- endif %}
              "nsosversion": "{{ grains['os'] }} {{ grains['osmajorrelease'] }}",
              "userpassword": "{{ otp }}",
              "version": "{{ client.apiversion }}"
            }
          ]
        }' https://{{ ipaservers[0] }}/ipa/json
    - require:
      - cmd: ipa_get_ticket
    - require_in: 
      - cmd: ipa_client_install
    - onchanges:
      - file: ipa_service_principal

{%- if pillar.freeipa.server is defined %}
ipa_host_add_ipaservers:
  cmd.run:
    - name: >
        curl -k -s
        -H referer:https://{{ ipaservers[0] }}/ipa
        --negotiate -u :
        -H "Content-Type:application/json"
        -H "Accept:applicaton/json"
        -c /tmp/cookiejar -b /tmp/cookiejar
        -X POST
        -d '{
          "id": 0,
          "method": "hostgroup_add_member/1",
                    "params": [
            [
                  "ipaservers"
            ],
            {
                "host": [
                    "{{ client.get("hostname", {})  }}"
                ],
                "version": "2.228"
            }
          ]
        }' https://{{ ipaservers[0] }}/ipa/json
    - require:
      - cmd: ipa_get_ticket
    - require_in: 
      - cmd: ipa_client_install
    - onchanges:
      - file: ipa_service_principal
{%- endif %}

{# cleanup #}
ipa_cleanup_cookies:
  file.absent:
    - name: /tmp/cookiejar
    - require:
      - cmd: ipa_host_add
    - require_in:
      - cmd: ipa_client_install
    - onchanges:
      - cmd: ipa_host_add

ipa_cleanup_keytab:
  file.absent:
    - name: /tmp/service.keytab
    - require:
      - cmd: ipa_host_add
    - require_in:
      - cmd: ipa_client_install
    - onchanges:
      - cmd: ipa_host_add

ipa_kdestroy:
  cmd.run:
    - name: kdestroy
    - require:
      - cmd: ipa_host_add
    - require_in:
      - cmd: ipa_client_install
    - onchanges:
      - file: ipa_service_principal

{% endif -%}

{%- if client.get('enabled', False) %}

ipa_client_install:
  cmd.run:
    - name: >
        ipa-client-install
        --domain {{ client.domain }}
        --realm {{ client.realm }}
        --hostname {{ ipahost }}
        {%- if otp is defined %}
        -w {{ otp }}
        {%- else %}
        -w {{ client.otp }}
        {%- endif %}
        {%- if client.get('mkhomedir', True) %} --mkhomedir{%- endif %}
        {%- if client.dns.updates %} --enable-dns-updates{%- endif %}
        --unattended
    - creates: /etc/ipa/default.conf
    - require:
      - pkg: ipa_client_packages
    - require_in:
      - file: sssd_config
      - file: krb5_conf
    {%- if client.install_principal is defined %}
    - onchanges:
      - file: ipa_service_principal
    {%- endif %}

{%- endif %}

