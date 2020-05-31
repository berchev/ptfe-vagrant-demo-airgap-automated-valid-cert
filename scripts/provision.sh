 #!/usr/bin/env bash

 # Debug mode - uncomment in order to turn it on
 set -x

 ########################
 # Variables definition #
 ########################

# Snapshots path
 path="/var/lib/replicated/snapshots"

#######################
# Function definition #
#######################

# The function is measuring the time needed to complete the task PTFE Installation/Restore
Time_Measure_Func () {
    STARTED_AT=${SECONDS}
        until curl -f -s --connect-timeout 1 http://localhost/_health_check; do
            sleep 1
            echo "Initializing... please wait!"
        done
    FINISHED_AT=$((${SECONDS} - ${STARTED_AT}))
    echo "$((${FINISHED_AT} / 60)) minutes and $((${FINISHED_AT} % 60)) seconds"
}

#####################
# Main script start #
#####################

# Check whether we have any snapshots, if "true" => perform restore from snapshot
if [ "$(ls -A ${path}/sha256)" ]
then 
    # Configure replicated
    curl ${ptfe_url} | bash -s fast-timeouts private-address=${ip_address} no-proxy public-address=${ip_address}

    # This retrieves a list of all the snapshots currently available.
    replicatedctl snapshot ls --store local --path ${path} -o json > /tmp/snapshots.json

    # Pull just the snapshot id out of the list of snapshots
    id=$(jq -r 'sort_by(.finished) | .[-1].id // ""' /tmp/snapshots.json)

    # Perform restore from latest snapshot
    replicatedctl snapshot restore $access --dismiss-preflight-checks "$id"
    sleep 5
    # Without restarting replicated and then starting the app, PTFE instance didn't start
    service replicated restart
    service replicated-ui restart
    service replicated-operator restart
    sleep 60
    replicated app $(replicated apps list | grep "Terraform Enterprise" | awk {'print $1'}) start

    # Just a timer, I want to measure the amount of time needed for the snapshot restore
    Time_Measure_Func 
    echo "were required to complete the PTFE Restore from snapshot"
# If which replicated finish with status 0, then TFE is alredy installed. Do nothing, just start the VM
elif [ "$(which replicated)" ]
then
    echo TFE already installed, there is no any snapshots...
else
    # Install Docker CE

    apt-get update
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg-agent \
    software-properties-common \

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    apt-key fingerprint 0EBFCD88



    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

    apt-get update

    apt-get install -y docker-ce=5:18.09.2~3-0~ubuntu-bionic docker-ce-cli=5:18.09.2~3-0~ubuntu-bionic containerd.io

    groupadd docker
    usermod -aG docker vagrant

    sudo systemctl enable docker

    # Perform brand new instalation of TFE
    #cp /vagrant/conf/replicated.conf /etc/replicated.conf
    cat <<- EOF > /etc/replicated.conf
    {
        "DaemonAuthenticationType":          "password",
        "DaemonAuthenticationPassword":      "Password123#",
        "TlsBootstrapType":                  "server-path",
        "TlsBootstrapHostname":              "tfe.georgiman.com",
        "TlsBootstrapCert":                  "/vagrant/sensitive/fullchain.pem",
        "TlsBootstrapKey":                   "/vagrant/sensitive/privkey.pem",
        "BypassPreflightChecks":             true,
        "ImportSettingsFrom":                "/vagrant/sensitive/settings.json",
        "LicenseFileLocation":               "/vagrant/sensitive/hashicorp-support-sofia.rli",
        "LicenseBootstrapAirgapPackagePath": "/tmp/${tfe_airgap_package}"
    }
EOF

    chmod 644 /etc/replicated.conf
    cp /vagrant/assets/replicated.tar.gz /tmp 2>&1 | tee /tmp/cp_relicated.log
    cp /vagrant/assets/${tfe_airgap_package} /tmp 2>&1 | tee /tmp/cp_airgap.log
    
    pushd /tmp
    tar xzf replicated.tar.gz
    ./install.sh \
    airgap \
    no-proxy \
    private-address=${ip_address} \
    public-address=${ip_address} | tee /tmp/install.log

    # Just a timer, I want to measure the amount of time needed for the instalation
    Time_Measure_Func 
    echo "were required to complete the PTFE Installation"
fi