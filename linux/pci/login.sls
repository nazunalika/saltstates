useradd:
  file.managed:
    - name: /etc/default/useradd
    - source: salt://linux/pci/files/useradd
    - mode: 600
    - user: root
    - group: root

login_defs:
  file.managed:
    - name: /etc/login.defs
    - contents_pillar: auth:logindefs
    - mode: 644
    - user: root
    - group: root
    - template: jinja

pwquality_conf:
  file.managed:
    - name: /etc/security/pwquality.conf
    - source: salt://linux/pci/files/pwquality.conf
    - user: root
    - group: root
    - mode: 644

{# issue #}

cron_perms:
  file.managed:
    - name: /etc/cron.allow
    - user: root
    - group: root
    - mode: 600
    - replace: False

at_perms:
  file.managed:
    - name: /etc/at.allow
    - user: root
    - group: root
    - mode: 600
    - replace: False

cron_prepend:
  file.prepend:
    - name: /etc/cron.allow
    - text:
      - root

at_prepend:
  file.prepend:
    - name: /etc/at.allow
    - text:
      - root

cron_deny_remove:
  file.absent:
    - name: /etc/cron.deny

at_deny_remove:
  file.absent:
    - name: /etc/at.deny

{#
root_cron_disable_accounts:
  cron.present:
    - name: useradd -D -f 30 >/dev/null 2>&1
    - identifier: DISABLEUSER35
    - user: root
    - minute: 5
    - hour: 5
#}
