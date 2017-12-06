ipxe
=====

Formula to deploy ipxe for PXE boot based on TFTP and web server.

Tested with CentOS 7.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``ipxe``
---------

Install packages (defaults.yaml/map.jinja or custom pillar data)
Copy boot images to tftp root if configured to do so (custom pillar data)
Copy web content to web root if configured to do so (custom pillar data)
Generate config files in web root if configured to do so (custom pillar data)
