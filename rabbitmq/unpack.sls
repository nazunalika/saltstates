{% from "rabbitmq/map/map.jinja" import rabbitmq with context %}

include:
  - .packages

rabbitmq_unpack:
  archive.extracted:
    - name: /opt
    - source: {{ rabbitmq.source }}
    - source_hash: sha256={{ rabbitmq.hash }}
    - archive_format: tar
    - if_missing: {{ rabbitmq.homedir }}/sbin/rabbitmq
    - require:
      - pkg: rabbitmq_dependencies
    - require_in:
      - file: rabbitmq_service
      - service: rabbitmq_service

  file.directory:
    - name: {{ rabbitmq.homedir }}
    - mode: 755
    - user: rabbitmq
    - group: rabbitmq
    - recurse:
      - user
      - group

rabbitmq_link:
  file.symlink:
    - name: {{ rabbitmq.home }}
    - target: {{ rabbitmq.homedir }}
    - user: rabbitmq
    - group: rabbitmq

rabbitmq_service:
  file.managed:
    - name: {{ rabbitmq.location }}
    - user: root
    - group: root
    - mode: {{ rabbitmq.serviceperm }}
    - source: salt://rabbitmq/files/{{ rabbitmq.servicename }}

  service.running:
    - name: {{ rabbitmq.service }}
    - enable: True

rabbitmq_remove_old:
  file.absent:
    - name: {{ pillar['hashes']['rabbitmq'][rabbitmq.old_version]['homedir'] }}

