{% set os = 'el' ~ grains['osmajorrelease'] %}

audit:
  pkg.installed:
    - name: audit

  service.running:
    - name: auditd
    - enable: True
    - watch:
      - pkg: audit
      - file: audit_rules

audit_rules:
  file:
    - managed
    - name: /etc/audit/rules.d/audit.rules
    - source: salt://linux/pci/files/{{ os }}-audit.rules
    - mode: 640
    - template: jinja
    - makedirs: True
    - require:
      - pkg: audit
    - watch_in:
      - service: audit

cis_audit_rules:
  file.managed:
    - name: /etc/audit/rules.d/cis.rules
    - contents_pillar: audit:rules
    - mode: 640
    - require:
      - pkg: audit
    - watch_in:
      - service: audit

generate_rules:
  cmd.run:
    - name: /sbin/augenrules

restart_audit_service:
  cmd.run:
    - name: /sbin/service auditd restart

