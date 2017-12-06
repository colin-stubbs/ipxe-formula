{# ipxe #}

{% from "ipxe/map.jinja" import ipxe_settings with context %}

{% if 'pkgs' in ipxe_settings.lookup %}
ipxe-pkgs:
  pkg.installed:
    - pkgs: {{ ipxe_settings.lookup.pkgs }}
{% endif %}

{% if 'copy' in ipxe_settings %}
{% if 'boot_images' in ipxe_settings.copy %}
{% for boot_image in ipxe_settings.copy.boot_images %}
ipxe-boot-image-{{ boot_image }}:
  file.managed:
    - source: {{ ipxe_settings.lookup.locations.boot_images }}/{{ boot_image }}
    - name: {{ ipxe_settings.lookup.locations.tftp_root }}/{{ boot_image }}
    - user: {{ ipxe_settings.copy.user|default('root') }}
    - group: {{ ipxe_settings.copy.group|default('root') }}
    - mode: {{ ipxe_settings.copy.mode|default('0444') }}
{% endfor %}
{% endif %}

{% if 'web_content' in ipxe_settings.copy %}
ipxe-{{ ipxe_settings.lookup.locations.web_root }}:
  file.directory:
    - makedirs: True
    - name: {{ ipxe_settings.lookup.locations.web_root }}
    - source: {{ ipxe_settings.copy.web_content }}
    - user: {{ ipxe_settings.copy.user|default('root') }}
    - group: {{ ipxe_settings.copy.group|default('root') }}
    - dir_mode: {{ ipxe_settings.copy.dir_mode|default('0755') }}
    - file_mode: {{ ipxe_settings.copy.file_mode|default('0444') }}
    - recurse:
      - user
      - group
      - mode

ipxe-web-content-restorecon:
  cmd.run:
    - name: restorecon -R {{ ipxe_settings.lookup.locations.web_root }}
    - watch:
      - file: ipxe-{{ ipxe_settings.lookup.locations.web_root }}
{% endif %}
{% endif %}

{% if 'config' in ipxe_settings %}
ipxe-web-content-directory:
  file.directory:
    - makedirs: True
    - name: {{ ipxe_settings.lookup.locations.web_root }}
    - user: {{ ipxe_settings.config.user|default('root') }}
    - group: {{ ipxe_settings.config.group|default('root') }}
    - dir_mode: {{ ipxe_settings.config.dir_mode|default('0755') }}
    - file_mode: {{ ipxe_settings.config.file_mode|default('0444') }}

{% for config_name, config_attributes in ipxe_settings.config.items() %}
ipxe-config-{{ config_name }}:
  file.managed:
    {% if 'name' in config_attributes %}
    - name: {{ ipxe_settings.lookup.locations.web_root }}/{{ config_attributes.name }}
    {% else %}
    - name: {{ ipxe_settings.lookup.locations.web_root }}/{{ config_name }}.ipxe
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
