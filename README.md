# ptfe-vagrant-demo-airgap-automated-valid-cert

The repo is just an example how to perform TFE version 4 automated with valid certificate.
- local instalation 
- restore from snapshot

We are going to use vagrant in order to create appropriate development environment for that.
Our VM configuration include:
- private IP address (192.168.56.33) 
- /dev/mapper/vagrant--vg-root 83GB
- /dev/mapper/vagrant--vg-var_lib 113G

## Repo Content
| File                   | Description                      |
|         ---            |                ---               |
| [Vagrantfile](Vagrantfile) | Vagrant template file. TFE env is going to be cretated based on that file|
| [delete_all.sh](delete_all.sh) | Purpose of this script is to break our environment. We will use it during snapshot restore|
|[scripts/provision.sh](scripts/provision.sh)| depends on some checks, this script will perform TFE install or restore|
|[assets/README.md](assets/README.md)| Place replicated.tar.gz and .airgap package|
|[sensitive directory](sensitive)|contain all sensitive information (valid TLS/SSL certificates, TFE license, TFE app settings) |


## Requirements
Please make sure you have fullfilled the reqirements before continue further:
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads) installed
- Hashicorp [Vagrant](https://www.vagrantup.com/) installed
- [Basic Vagrant skills](https://www.vagrantup.com/intro/getting-started/) 
- Perform [manual TFE instalation with valid certificate](https://github.com/berchev/ptfe-demo-mode-valid-cert)
  - once installation is performed, ssh to ptfe vagrant box
  ```
  vagrant ssh
  ```
  - change to /vagrant directory (the directory synced with your host machine)
  ```
  cd /vagrant
  ```
  - extract the configuration of Terraform Enterprise application in JSON format
  ```
  replicatedctl app-config export > settings.json
  ```
- Into `sensitive` folder you need to place
  - settings.json file which you just extracted or use the minimal one provided in the repo.
  - PTFE license, `.rli` file (You can contact Sales Team of HashiCorp - sales@hashicorp.com in order to purchase one)
  - your own SSL/TLS certificates - In case you do not have such, you can generate for free using [Let's encrypt](https://letsencrypt.org/) 
    - fullchain.pem
    - privkey.pem
- Make sure, that you will edit [conf/replicated.conf](conf/replicated.conf) fille according to your needs (adjust domain, password and files pointing to `sensitive` directory)

## Getting started
- Clone this repo locally
```
git clone https://github.com/berchev/ptfe-vagrant-demo-airgap-automated-valid-cert
```
- Change into downloaded repo directory
```
cd ptfe-vagrant-demo-airgap-automated-valid-cert
```

## PTFE version 4 automated install
- Start provision vagrant development environment (during VM provision, provision.sh script will perform automated install of TFE)
```
vagrant up
```
- at some point you will see, on your console, continuous output like this one:
```
default: Initializing... please wait!
default: Initializing... please wait!
default: Initializing... please wait!
```
