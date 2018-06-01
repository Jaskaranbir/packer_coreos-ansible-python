## Core-OS with Python, Ansible, and Docker-Compose

This is the packer configuration for building Core-OS image with pre-setup Python, Ansible, and Docker-Compose.

**Currently based on version 1745.5.0.**

**Vagrant-Cloud Link**: https://app.vagrantup.com/jaskaranbir/boxes/coreos-ansible

### About

This configuration targets **Vagrant-VirtualBox** only (at the moment).
So it generates a Vagrant box.
However, other targets such as VMWare can be easily added.

This is the latest stable release (as per commit-date) for the Core-OS.
It uses [ActivePython][1] for Python, and installs Ansible using PIP.

By deafult, Ignition is only used to insert the Vagrant insecure key.
Since ignition is already used, **do not use Ignition again to orchestrate the OS**.
This might cause problems (suchas failure to boot). Instead, use Ansible.

### Why

This is intended to orchestrate the local environment for Vagrant-VirtualBox.

Including Ansible within the Box will allow developers to directly use Vagrant's
Ansible provisioning without having to actually install Ansible on their local.
Hence, the complete setup can be automated.

### Running the Box using Vagrant

The Vagrantfile provided at the root of repo can be used as a base Vagrantfile (its further based on [Core-OS Vagrant][2]'s Vagrantfile).

When running `vagrant up`, you might see some SSH failure messages such as:

`core-01: Warning: Connection reset. Retrying...`

This is normal. Core-OS takes a little while to boot, so Vagrant will just
have to keep retrying to SSH until th VM is booted and SSH is ready to go.
Feel free to take a look at GUI in VirtualBox to see what's happening
(also helps in debugging).

### Building the image

#### Using Makefile

* Run `make build` to build the image. This also enables debugging options by default.
This will also generate a log file with the Packer output.

* Run `make build-d` to build without debugging options.

* Check out Makefile for all targets

#### Without using Makefile

The usual Packer command: `packer build coreos.json`

### Testing the Box

A basic "test-suite" (is it even enough to be called a *Test-Suite*?) bash script
can be found in "tests" directory. The simple script simply checks if all
binaries: Python, Ansible, Docker-Compose are accessible by the system.

The tests are automatically run after evey Packer build, and the Packer build
won't succeed unless are tests are passed.

#### Running the test:

Using make: `make test`.

Manual Testing: Just execute `tests/basic_test_suite.sh`.

### FAQs

* **Do you intend to suport any other options such as VMWare?**

No, no such plans yet. As I said earlier, it should be easy to extend this configuration
to other hypervisors. I like free stuff; VirtualBox is free, and simple.

* **Why not use Vagrantfile to setup all this?**

A pre-packaged box such as this ensures consistency and makes environment less error-prone.
Additionally, this is usually the base setup for my Vagrant these days.

 [1]: https://www.activestate.com/activepython
 [2]: https://github.com/coreos/coreos-vagrant
