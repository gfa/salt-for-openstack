Salt States for OpenStack
========================


This very simple states can configure OpenStack using salt, they can configure keystone, glance, nova and neutron.
tested on ubuntu and debian, icehouse, juno and kilo releases.

I may add another states later, as i use this repo to drive my testing, i rebase my production from this repo.

Directories
-----


pillar:

its the *pillar_roots*


states:

its the *file_roots*


states/cloud:
openstack states


after installing all the software and configurations, a bunch of files on the root user homedir will be created they will create network, images, etc.
I'm in the process to move those files to salt modules which will do the same. I plan to use https://github.com/fraunhoferfokus/openstack-formula

NOTES
---

- For simplicity only *base* environment is configured.

- If you are looking for formulas, like Puppet modules for OpenStack, you won't find them here.
I don't like complex formulas and I don't use them as I found them hard to explain or follow.
I use simple state files where pkgs are installed, config files are generated and services are enabled/started/restarted/reload

- There are keys in the repo, i plan to move them to pillar then to a private location, but as I don't use this directly on production it may take a while.
- Same with pillar values, I don't consider them private.