# TFE IP Address
ptfe_ip = "192.168.56.33"
# Airgap package
tfe_airgap_package = "v202004-2.airgap"

Vagrant.configure("2") do |config|
  config.vm.box = "berchev/bionic64"
  config.vm.hostname = "ptfe"
  config.vm.network "private_network", ip: ptfe_ip
  config.vm.provision :shell, path: "scripts/provision.sh", env: { "ip_address" => ptfe_ip, "tfe_airgap_package" => tfe_airgap_package}
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024 * 8
    v.cpus = 2
  end
end

