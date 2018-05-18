# Vagrant LA(T)MP Stack

**Vagrant CentOS 7 + Apache HTTP + Apache Tomcat + MySQL + PHP**

## Usage

Manually [Install Vagrant](https://www.vagrantup.com) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

… **OR**, macOS users, install using [Homebrew](https://brew.sh/):

```bash
$ brew cask install virtualbox vagrant vagrant-manager
# Bonus! Use this to update previously installed casks:
$ brew cask outdated | xargs brew cask reinstall
```

Next, create a directory for your Vagrant projects; I put mine here:

```text
~/dev/vagrant/<name of project>
```

Navigate to `vagrant/<name of project>` and install this code using one of these options:

1. From the command line: `$ bash <(curl -sL https://git.io/vQbL5)`
1. Download as a [`zip`](../../archive/master.zip)
1. Clone it: `$ git clone https://github.com/mhulse/vagrant-latmp.git .`
1. Fork it and clone: `$ git clone git@github.com:<username>/vagrant-latmp.git .`

Once installed, run:

```bash
$ vagrant up
```

This command will download (first time installs), configure (using [`bootstrap/init.sh`](init.sh)) and start the virtual machine.

Note that several useful “[synced folders](https://www.vagrantup.com/docs/synced-folders/basic_usage.html)” will appear at the project’s root:

- `http/www/` (`/var/www/`)
- `http/conf.d/` (`/etc/httpd/conf.d/`)
- `tomcat/webapps/` (`/var/lib/tomcat/webapps/`)
- `tomcat/conf/` (`/etc/tomcat/`)
- `tomcat/log/` (`/var/log/tomcat/`)
- `node/` (`/var/node/`)

> Synced folders enable Vagrant to sync a folder on the host machine to the guest machine, allowing you to continue working on your project's files on your host machine, but use the resources in the guest machine to compile or run your project.

Once the VM is up, you can ssh into the current running Vagrant box:

```bash
$ vagrant ssh
```

You are now connected to the Vagrant box at `/home/vagrant`. Note that you can access the host machine at `/vagrant`.

## Demo pages

On the “host” computer (i.e. **NOT** the VM), add these lines to your hosts file:

```text
<ip> http.local
<ip> tomcat.local
<ip> node.local
```

On macOS, the hosts file is located at `/private/etc/hosts`; after editing this file, run `dscacheutil -flushcache` from the command line.

In your browser, visit <http://http.local>, <http://tomcat.local> and <http://node.local> to view the demo Apache HTTP, Apache Tomcat and Node.js pages, respectively.

## Options

This option can be set in the [`Vagrantfile`](Vagrantfile):

- `NETWORK_IP`: Leave blank for DHCP (default), or `192.168.x.x` for a static IP
- `NETWORK_TYPE`: Valid values: `public` (default) or `private`
- `VM_MEMORY`: VM RAM usage.
- `VM_CPUS`: VM CPU count.
- `VM_CPU_CAP`: CPU execution cap percentage.

These options can be adjusted in the [`bootstrap/init.sh`](bootstrap/init.sh):

- `PHP_VERSION`: Valid values: `5.6`, `7.0`, `7.1`, `7.2`
- `PHP_MEMORY_LIMIT`
- `PHP_TIMEZONE`
- `PHP_MAX_EXECUTION_TIME`
- `NODE_VERSION`
- `GIT_CONFIG_NAME`
- `GIT_CONFIG_EMAIL`
- `RUBY_VERSION`

## Vagrant tips

Here’s a few useful commands:

```bash
# Start VM:
$ vagrant up
# Reload, no provision:
$ vagrant reload
# Reload and provision:
$ vagrant reload --provision
# SSH into VM:
$ vagrant ssh
# Suspend VM rather than fully shutting it down or destroying it:
$ vagrant suspend
# Resume previously suspended VM:
$ vagrant resume
# Shut down VM:
$ vagrant halt
# Terminate the use of any resources by the virtual machine:
$ vagrant destroy
# Completely remove the box file:
$ vagrant box remove
```

A full list of Vagrant’s CLI commands can be found here: [Command-Line Interface](https://www.vagrantup.com/docs/cli/).

When running `vagrant up`, Vagrant will install dependencies as defined by the provisioning script(s); this is called “[Automatic Provisioning](https://www.vagrantup.com/intro/getting-started/provisioning.html)”.

If you make any modifications to the [`Vagrantfile`](Vagrantfile), `reload` should be called.

If you make changes to your `Vagrantfile`’s provisioner’s (i.e., any shell scripts in [`bootstrap/`](bootstrap/)), you’ll want to call `reload --provision`.

## Programming tips

- Use `10.0.2.2` if you want to connect to a MySQL database on the host machine.
- phpMyAdmin can be accessed at `<ip>/phpmyadmin` or `http.local/phpmyadmin`; login using `root` with no password.
- MailCatcher can be accessed at `<ip>:1080`; if not accessible, you may need to run this command as root: `mailcatcher --ip=0.0.0.0`.

## Links

Big ups:

- [Vagrant PHP7: A simple Vagrant LAMP setup running PHP7](https://github.com/spiritix/vagrant-php7)
- [Vagrant Skeleton: A base CentOS vagrant setup good for SilverStripe and other PHP frameworks](https://github.com/BetterBrief/vagrant-skeleton/blob/master/Vagrantfile).

---

Copyright © 2017 [Michael Hulse](http://mky.io).

Licensed under the Apache License, Version 2.0 (the “License”); you may not use this work except in compliance with the License. You may obtain a copy of the License in the LICENSE file, or at:

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

<img src="https://github.global.ssl.fastly.net/images/icons/emoji/octocat.png">
