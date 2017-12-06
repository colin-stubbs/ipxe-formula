{# ipxe #}

{% from "ipxe/map.jinja" import ipxe with context %}

{% if 'pkgs' in ipxe.lookup %}
ipxe-pkgs:
  pkg.installed:
    - pkgs: {{ ipxe.lookup.pkgs }}
{% endif %}

{% if 'copy' in ipxe %}
{% if 'boot_images' in ipxe.copy %}
{% for boot_image in ipxe.copy.boot_images %}
ipxe-boot-image-{{ boot_image }}:
  file.managed:
    - source: {{ ipxe.lookup.locations.boot_images }}/{{ boot_image }}
    - name: {{ ipxe.lookup.locations.tftp_root }}/{{ boot_image }}
    - user: {{ ipxe.copy.user|default('root') }}
    - group: {{ ipxe.copy.group|default('root') }}
    - mode: {{ ipxe.copy.mode|default('0444') }}
{% endfor %}
{% endif %}

{% if 'web_content' in ipxe.copy %}
ipxe-{{ ipxe.lookup.locations.web_root }}:
  file.directory:
    - makedirs: True
    - name: {{ ipxe.lookup.locations.web_root }}
    - source: {{ ipxe.copy.web_content }}
    - user: {{ ipxe.copy.user|default('root') }}
    - group: {{ ipxe.copy.group|default('root') }}
    - dir_mode: {{ ipxe.copy.dir_mode|default('0755') }}
    - file_mode: {{ ipxe.copy.file_mode|default('0444') }}
    - recurse:
      - user
      - group
      - mode

ipxe-web-content-restorecon:
  cmd.run:
    - name: restorecon -R {{ ipxe.lookup.locations.web_root }}
    - watch:
      - file: ipxe-{{ ipxe.lookup.locations.web_root }}
{% endif %}
{% endif %}

{% if 'config' in ipxe %}
ipxe-web-content-directory:
  file.directory:
    - makedirs: True
    - name: {{ ipxe.lookup.locations.web_root }}
    - user: {{ ipxe.config.user|default('root') }}
    - group: {{ ipxe.config.group|default('root') }}
    - dir_mode: {{ ipxe.config.dir_mode|default('0755') }}
    - file_mode: {{ ipxe.config.file_mode|default('0444') }}

{% for config_name, config_attributes in ipxe.config.items() %}
ipxe-config-{{ config_name }}:
  file.managed:
    {% if 'name' in config_attributes %}
    - name: {{ ipxe.lookup.locations.web_root }}/{{ config_attributes.name }}
    {% else %}
    - name: {{ ipxe.lookup.locations.web_root }}/{{ config_name }}.ipxe
    {% endif %}
    - source: {{ config_attributes.source }}
    {% if 'template' in config_attributes %}
    - template: {{ config_attributes.template }}
    {% endif %}
    {% if 'context' in config_attributes %}
    - context:
    {% for context_name, context in config_attributes %}
      {{ context_name }}: {{ context }}
    {% endfor %}
    {% endif %}
    - require:
      - file: ipxe-web-content-directory
{% endfor %}

{% endif %}

{# EOF #}
