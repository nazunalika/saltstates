freeipa:
  client:
    enabled: True
    server: np-ipa01.ipa.example.com
    realm: IPA.EXAMPLE.COM
    domain: ipa.example.com
    topdomain: example.com
    basedn: dc=ipa,dc=example,dc=com
    otp: B1gp3n15
    hostname: {{ salt['grains.get']('fqdn', '') }}
    servers:
      - np-ipa01.ipa.example.com
      - np-ipa02.ipa.example.com
      - on-ipa01.ipa.example.com
      - on-ipa02.ipa.example.com
    apiversion: 2.228
    install_principal:
      source: salt://freeipa/files/principal.keytab
      principal_user: "add_sys_host"
    solarisBind: uid=solaris,cn=sysaccounts,cn=etc,dc=ipa,dc=example,dc=com
    solarisPass: qdbKnW1et
    dns:
      delegated: True
