freeipa:
  server:
    enabled: True
    realm: IPA.EXAMPLE.COM
    domain: ipa.example.com
    topdomain: example.com
    basedn: dc=ipa,dc=example,dc=com
    ca: True
    dns:
      delegated: True
      enabled: True
      forwarders:
        - 192.168.10.10
        - 192.168.11.10
    no_host_dns: False
    ntp:
      enabled: False
    mkhomedir: True
    principal_user: admin
    servers:
      - np-ipa01.ipa.example.com
      - np-ipa02.ipa.example.com
      - on-ipa01.ipa.example.com
      - on-ipa02.ipa.example.com
    admin:
      password: SECRET123
    ldap:
      password: SECRET123
    add_sys_host:
      password: SECRET456
    apiversion: 2.228
