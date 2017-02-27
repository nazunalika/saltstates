{% set pget = salt['pillar.get'] %}
{% for name, firewall in pillar.get('firewalld', {}).items() %}

{% if firewall == None %}
{% set firewall = {} %}
{% endif %}

{% set current = salt.user.info(name) %}
{% set firewallfile = firewall.get('file', current.get('file', "/etc/firewalld/services/%s" % name)) %}

firewalld_{{ name }}_file:
  file.managed:
    - name: {{ firewallfile }}
    - user: root
    - group: root
    - mode: 644
    - contents_pillar: firewalld:{{ name }}:content

{% endfor %}

