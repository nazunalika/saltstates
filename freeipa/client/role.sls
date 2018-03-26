{%- from "freeipa/map/map.jinja" import client, ipahost, ipaservers with context %}
{% set os = 'rhel' ~ grains['osmajorrelease'] %}

{#
  We are adding our system to specific host groups based on their role. So for example,
  are we middleware? Are we web? Are we weblogic? The list goes on. If a role is not
  defined, this is ignored.

  This is an example state and should be included in the "install" portion of the build.
#}

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

ipa_host_add_group:
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
                  "{{ client.ipagroup }}"
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
    - name: /tmp/principal.keytab
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

{%- endif %}

