{% from "linux/auth/map/map.jinja" import auth with context %}

pam_requiredpkgs:
  pkg.installed:
    - pkgs:
      - authconfig
      - pam

system-auth-ac:
  file.managed:
    - name: /etc/pam.d/system-auth-ac
    - contents_pillar: auth:system-auth
    - mode: 644
    - require:
      - pkg: pam_requiredpkgs

password-auth-ac:
  file.managed:
    - name: /etc/pam.d/password-auth-ac
    - contents_pillar: auth:system-auth
    - mode: 644
    - require:
      - pkg: pam_requiredpkgs

{# this is because some systems don't have this available #}

system-auth-symlink:
  file.symlink:
    - name: /etc/pam.d/system-auth
    - target: /etc/pam.d/system-auth-ac

password-auth-symlink:
  file.symlink:
    - name: /etc/pam.d/password-auth
    - target: /etc/pam.d/password-auth-ac
