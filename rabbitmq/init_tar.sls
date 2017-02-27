{% from "rabbitmq/map.jinja" import rabbitmq with context %}

include:
  - users

rabbitmq_unpack:
  archive.extracted:
    - name: /opt
    - source: {{ pillar['hashes']['rabbitmq'][rabbitmq.version]['source'] }}
    - source_hash: md5={{ pillar['hashes']['rabbitmq'][rabbitmq.version]['hash'] }}
    - archive_format: tar
    - if_missing: /opt/rabbitmq_server-{{ rabbitmq.version }}/sbin/rabbitmq

  file.directory:
    - name: /opt/rabbitmq_server-{{ rabbitmq.version }}
    - mode: 755
    - user: rabbitmq
    - group: rabbitmq
    - recurse:
      - user
      - group

  pkg.installed:
    - pkgs:
      - erlang-eldap
      - erlang-asn1
      - erlang-compiler
      - erlang-crypto
      - erlang-erts
      - erlang-hipe
      - erlang-inets
      - erlang-kernel
      - erlang-mnesia
      - erlang-os_mon
      - erlang-otp_mibs
      - erlang-public_key
      - erlang-runtime_tools
      - erlang-sasl
      - erlang-sd_notify
      - erlang-snmp
      - erlang-ssl
      - erlang-stdlib
      - erlang-syntax_tools
      - erlang-tools
      - erlang-xmerl
      - lksctp-tools
    - refresh: True

rabbitmq_link:
  file.symlink:
    - name: /opt/rabbitmq
    - target: /opt/rabbitmq_server-{{ rabbitmq.version }}
    - user: rabbitmq
    - group: rabbitmq

rabbitmq_service:
  file.managed:
    - name: {{ rabbitmq.serviceloc }}
    - user: root
    - group: root
    - mode: {{ rabbitmq.serviceperm }}
    - source: salt://rabbitmq/files/{{ rabbitmq.servicename }}

  service.running:
    - name: {{ rabbitmq.service }}
    - provider: {{ rabbitmq.provider }}
    - enable: True

{% if salt['grains.get']('osmajorrelease') == '7' %}
rabbitmq_firewall_change:
  cmd.run:
    - name: /bin/firewall-cmd --add-service=rabbitmq --permanent ; /bin/firewall-cmd --add-service=rabbitmq
{% endif %}
