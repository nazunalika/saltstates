## User Accounts
#
#  This applies for systems that have a common "role". It does not account for one-offs.

{% set pget = salt['pillar.get'] %}
{% set override_user = pget("overrideuser") %}
{% for name, user in pillar.get('users', {}).items() %}

{% if user == None %}
{% set user = {} %}
{% endif %}

{% set current = salt.user.info(name) %}
{% set home = user.get('home', current.get('home', "/home/%s" % name)) %}

## Setting the primary group. Some users have separate primary groups.
{% if 'primary_group' in user and 'name' in user['primary_group'] %}
{% set usergroup = user.primary_group.name %}
{% else %}
{% set usergroup = name %}
{% endif %}

## Here we're creating the group(s) required for the user
## This is a for loop to account for users who need more than one group
## The group GID's are listed in a separate pillar on purpose
{% if 'groups' in user %}
{% for group in user.get('groups', []) %}
users_{{ name }}_{{ group }}_group:
  group.present:
    - name: {{ group }}
    - gid: {{ pillar['groups'][group]['gid'] }}
{% endfor %}
{% endif %}

## There are some groups that just need to exist and do NOT require the account
## to be part of it. 

{% if 'groups_to_create' in user %}
{% for group in user.get('groups_to_create', []) %}
users_{{ name }}_{{ group }}_group_create:
  group.present:
    - name: {{ group }}
    - gid: {{ pillar['groups'][group]['gid'] }}
{% endfor %}
{% endif %}

## Creating the user account
users_{{ name }}_user:
  file.directory:
    - name: {{ home }}
    - user: {{ name }}
    - group: {{ usergroup }}
    - mode: 700
    - require:
      - user: users_{{ name }}_user
      - group: users_{{ name }}_{{ usergroup }}_group

## Ensuring the group exists - it should have been created
  group.present:
    - name: {{ usergroup }}
    {% if 'primary_group' in user and 'gid' in user['primary_group'] %}
    - gid: {{ user['primary_group']['gid'] }}
    {% elif 'uid' in user %}
    - gid: {{ user['uid'] }}
    {% endif %}

## Ensuring the user exists 
## We're checking for a "full name" and "password" if necessary
  user.present:
    - name: {{ name }}
    - home: {{ home }}
    - shell:  {{ user['shell'] }}
    - createhome: True
    - uid: {{ user['uid'] }}
    {% if 'primary_group' in user and 'gid' in user['primary_group'] %}
    - gid: {{ user['primary_group']['gid'] }}
    {% else %}
    - gid_from_name: True
    {% endif %}
    {% if 'password' in user %}
    - password: '{{ user['password'] }}'
    {% endif %}
    {% if 'fullname' in user %}
    - fullname: {{ user['fullname'] }}
    {% endif %}
    {% if 'system' in user %}
    - mindays: 0
    - maxdays: 99999
    - inactdays: -1
    - warndays: 7
    {% endif %}
    {% if 'groups' in user %}
    - optional_groups:
      {% for group in user.get('groups', []) %}
        - {{ group }}
      {% endfor %}
    {% endif %}

## Some accounts get created in /opt by default. This is here for those users.
## The pillar will need to have etc_skel with any value.
{# if 'etc_skel' in user %}
  cmd.run:
    - name: cp -n /etc/skel/.*rc {{ home }} ; cp -n /etc/skel/.bash_* {{ home }} ; chown -R {{ name }}:{{ usergroup }} {{ home }}
{% endif #}


## If the user have an ssh authorized keys, it will be created.
{% if 'sshauth' in user %}
  ssh_auth.present:
    - user: {{ name }}
    - names: 
      {{ user['sshauth']|yaml(false)|indent{6} }}

users_{{ name }}_ssh_dir:
  file.directory:
    - name: {{ home }}/.ssh
    - mode: 700
    - user: {{ name }}
    - group: {{ usergroup }}

## If the account MUST have an SSH private key, it will need the pub as well.
{% if 'sshpub' in user %}
users_{{ name }}_ssh_pub:
  file.managed:
    - name: {{ home }}/.ssh/id_rsa.pub
    - user: {{ name }}
    - group: {{ usergroup }}
    - mode: 644
    - source: {{ user['sshpub'] }}
{% endif %}
{% endif %}

## If they MUST have their private key on all servers (edge case), this is here.
{% if 'sshpriv' in user %}
users_{{ name }}_sshpriv:
  file.managed:
    - name: {{ home }}/.ssh/id_rsa
    - user: {{ name }}
    - group: {{ usergroup }}
    - mode: 400
    - makedirs: True
    - contents_pillar: users:{{ name }}:sshpriv

{% endif %}

## Extra directories (edge case)
## This should only be needed if the account needs something separate from its
## own directory for the application (eg, weblogic, oracle)
{% if 'directory' in user %}
{% for directory in user.get('directory', []) %}
users_{{ name }}_{{ directory }}:
  file.directory:
    - name: {{ directory }}
    - mode: 755
    - user: {{ name }}
    - group: {{ usergroup }}
{% endfor %}
{% endif %}

## Extra closed directories (edge case)
## This should only be needed for these reasons:
##   -> A log directory or other space that needs to be 700
##   -> The service account is in LDAP and hasn't been moved locally
{% if 'directory_closed' in user %}
{% for directory in user.get('directory_closed', []) %}
users_{{ name }}_{{ directory }}:
  file.directory:
    - name: {{ directory }}
    - mode: 700
    - user: {{ name }}
    - group: {{ usergroup }}
{% endfor %}
{% endif %}

## Symbolic Links (edge case)
{% if 'symlink' in user %}
{% for symlink in user.get('symlink', []) %}
{{ name }}_symlink_{{ symlink }}:
  file.symlink:
    - name: {{ pillar['users'][name]['symlink'][symlink]['from'] }}
    - target: {{ pillar['users'][name]['symlink'][symlink]['to'] }}
{% endfor %}
{% endif %}

## This is for normal cron jobs that an account needs
{% if 'cron' in user %}
{% for cron in user.get('cron', []) %}
users_{{ name }}_{{ cron }}_cron:
  cron.present:
    - name: {{ pillar['cron'][name][cron]['name'] }}
    - user: {{ pillar['cron'][name][cron]['user'] }}
    {% if pillar['cron'][name][cron]['hour'] is defined %}
    - hour: '{{ pillar['cron'][name][cron]['hour'] }}'
    {% endif %}
    {% if pillar['cron'][name][cron]['minute'] is defined %}
    - minute: '{{ pillar['cron'][name][cron]['minute'] }}'
    {% endif %}
    {% if pillar['cron'][name][cron]['daymonth'] is defined %}
    - daymonth: '{{ pillar['cron'][name][cron]['daymonth'] }}'
    {% endif %}
    {% if pillar['cron'][name][cron]['month'] is defined %}
    - month: '{{ pillar['cron'][name][cron]['month'] }}'
    {% endif %}
    {% if pillar['cron'][name][cron]['dayweek'] is defined %}
    - dayweek: '{{ pillar['cron'][name][cron]['dayweek'] }}'
    {% endif %}
    - identifier: {{ name }}_{{ cron }}_cron
{% endfor %}
{% endif %}

## GPG Keys
{% if 'gpgkey' in user %}
users_{{ name }}_gpgkey:
  file.managed:
    - name: {{ home }}/.usergpg.sec
    - mode: 600
    - user: {{ name }}
    - group: {{ usergroup }}
    - contents_pillar: users:{{ name }}:gpgkey:data

users_{{ name }}_gpgkey_import:
  cmd.run:
    - user: {{ name }}
    - name: gpg --import {{ home }}/.usergpg.sec
    - unless: gpg --list-keys {{ pillar['users'][name]['gpgkey']['id'] }}
    - require:
      - file: users_{{ name }}_gpgkey

users_{{ name }}_gpg_remove:
  file.absent:
    - name: {{ home }}/.usergpg.sec
    - require:
      - cmd: users_{{ name }}_gpgkey_import
{% endif %}

## This is for user limits.
{% if 'limits' in user %}
users_{{ name }}_limits:
  file.managed:
    - name: /etc/security/limits.d/90-{{ name }}.conf
    - mode: 644
    - user: root
    - group: root
    - contents_pillar: users:{{ name }}:limits
{% endif %}

## Extremely rare edge case, kernel parameters
{% if 'sysctl' in user %}
{% for sysctl in user.get('sysctl', []) %}
{{ sysctl }}:
  sysctl.present:
    - value: {{ user['sysctl'][sysctl] }}
    - config: /etc/sysctl.d/99-{{ name }}.conf
{% endfor %}
{% endif %}

## In the event we have custom profile information, we can pull it this way. This assumes the etc_skel state didn't execute
{% if 'etc_skel_bashrc' in user %}
users_{{ name }}_bashrc:
  file.managed:
    - name: {{ home }}/.bashrc
    - mode: 644
    - user: {{ name }}
    - group: {{ name }}
    - source: {{ pillar['users'][name]['etc_skel_bashrc'] }}
{% endif %}

{% if 'etc_skel_profile' in user %}
users_{{ name }}_profile:
  file.managed:
    - name: {{ home }}/.bash_profile
    - mode: 644
    - user: {{ name }}
    - group: {{ name }}
    - source: {{ pillar['users'][name]['etc_skel_profile'] }}
{% endif %}

{% if 'etc_skel_tmux' in user %}
users_{{ name }}_tmux:
  file.managed:
    - name: {{ home }}/.tmux.conf
    - mode: 644
    - user: {{ name }}
    - group: {{ name }}
    - source: {{ pillar['users'][name]['etc_skel_tmux'] }}
{% endif %}

{% if 'etc_skel_inputrc' in user %}
users_{{ name }}_inputrc:
  file.managed:
    - name: {{ home }}/.inputrc
    - mode: 644
    - user: {{ name }}
    - group: {{ name }}
    - source: {{ pillar['users'][name]['etc_skel_inputrc'] }}
{% endif %}

{% endfor %}

