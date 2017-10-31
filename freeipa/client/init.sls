{%- from "freeipa/map/map.jinja" import client, ipaservers with context %}
{#
  Client installation

  The reason why I'm doing this here is because each platform is different for how their client installs.
  For example, even though we can use sssd for legacy clients (RHEL 5), it's better to use pam_ldap when
  using a trust with domain resolution order set. There are some reasons for this which can be found on
  my FreeIPA guide. But also, BSD, MacOS, and Solaris are different beasts when configuring them for FreeIPA.
  This is why you'll find those clients have separate states entirely.
#}

{%- if ipaservers.0 != client.get('hostname', grains['fqdn']) %}

include:
  {{ client.clientsls|yaml(false)|indent(2) }}

{%- endif %}
