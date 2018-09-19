#!/bin/bash

authorized_keys=$1
email=$2

# Create a resource group.
echo
echo "Ctreating Resource Group..."
az group create --name tunnelingus --location westus2

# Create a virtual network.
echo
echo "Creating Virtual Network..."
az network vnet create --resource-group tunnelingus --name tunnelingus-vnet --subnet-name tunnelingus-subnet

# Create a random uuid for use as a DNS name and make sure it's valid.
# Needs to start with a letter so keep trying until we get a good one.
while true
do
    dnsname=$(uuidgen | tr [:upper:] [:lower:])
    [[ $dnsname =~ ^[a-z][a-z0-9-]{1,61}[a-z0-9]$ ]] && break 1
done

# Create a public IP address.
echo
echo "Creating Public IP Address..."
az network public-ip create --resource-group tunnelingus --name tunnelingus-ip --dns-name $dnsname

# Save the FQDN.
fqdn=$(az network public-ip show -g tunnelingus -n tunnelingus-ip --query "{fqdn: dnsSettings.fqdn}" --out tsv)

# Create a network security group.
echo
echo "Creating Network Security Group..."
az network nsg create --resource-group tunnelingus --name tunnelingus-nsg

# Create an inbound port rule for SSH (disabled by default, uncomment to enable).
#echo
#echo "Creating Inbound Port Rule for SSH..."
#az network nsg rule create \
#  --resource-group tunnelingus \
#  --nsg-name tunnelingus-nsg \
#  --name ssh-inbound \
#  --protocol tcp \
#  --priority 1000 \
#  --destination-port-range 22

# Create an inbound port rule for our tunnel.
echo
echo "Creating Inbound Port Rule for Tunnel..."
az network nsg rule create \
  --resource-group tunnelingus \
  --nsg-name tunnelingus-nsg \
  --name tunnel-inbound \
  --protocol tcp \
  --priority 1010 \
  --destination-port-range 2222

# Create an inbound port rule for HTTP (this is required by Let's Encrypt for HTTP challenge and is redirected to port 443 by nginx).
echo
echo "Creating Inbound Port Rule for HTTP..."
az network nsg rule create \
  --resource-group tunnelingus \
  --nsg-name tunnelingus-nsg \
  --name http-inbound \
  --protocol tcp \
  --priority 1020 \
  --destination-port-range 80

# Create an inbound port rule for HTTPS.
echo
echo "Creating Inbound Port Rule for HTTPS..."
az network nsg rule create \
  --resource-group tunnelingus \
  --nsg-name tunnelingus-nsg \
  --name https-inbound \
  --protocol tcp \
  --priority 1030 \
  --destination-port-range 443

# Create a virtual network card and associate with public IP address and NSG.
echo
echo "Creating NIC..."
az network nic create \
  --resource-group tunnelingus \
  --name tunnelingus-nic \
  --vnet-name tunnelingus-vnet \
  --subnet tunnelingus-subnet \
  --network-security-group tunnelingus-nsg \
  --public-ip-address tunnelingus-ip

# Create a new virtual machine, this creates SSH keys if not present.
echo
echo "Creating VM..."
az vm create \
  --resource-group tunnelingus \
  --name tunnelingus \
  --nics tunnelingus-nic \
  --image UbuntuLTS \
  --size Standard_B2s
#  --size Standard_B2s \
#  --admin-username tunnelingus \
#  --generate-ssh-keys

# Clone this repo to the VM.
echo
echo "Cloning https://github.com/sbardua/tunnelingus.git..."
az vm run-command invoke --resource-group tunnelingus --name tunnelingus --command-id RunShellScript --scripts "git clone https://github.com/sbardua/tunnelingus.git /opt/tunnelingus"

# Run setup script.
echo
echo "Running Setup Script..."
az vm run-command invoke --resource-group tunnelingus --name tunnelingus --command-id RunShellScript --scripts "/opt/tunnelingus/setup-azure-vm.sh $fqdn $email"

# Copy public key.
echo
echo "Copying Public SSH Key..."
az vm run-command invoke --resource-group tunnelingus --name tunnelingus --command-id RunShellScript --scripts "echo $authorized_keys > /opt/tunnelingus/authorized_keys"

# Start the reverse SSH tunnel.
echo
echo "Starting Tunnel..."
az vm run-command invoke --resource-group tunnelingus --name tunnelingus --command-id RunShellScript --scripts "cd /opt/tunnelingus && ./start.sh"

# Reboot the VM becasue reasons.
echo
echo "Rebooting VM"
az vm restart --resource-group tunnelingus --name tunnelingus

echo
echo "Done."
echo
echo "Run the following from the local system you will be tunelling from to verify the host key and check that the public key is setup correctly:"
echo
echo "ssh -p 2222 tunnelingus@$fqdn"
echo
echo "Then run the following to connect to your tunnel using autossh to ensure the tunnel stays up permanently:"
echo
echo "sudo apt-get -y install autossh && autossh -M 20000 -f -nNT -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ConnectTimeout=5 -g -R 8080:localhost:80 -p 2222 tunnelingus@$fqdn"
echo
echo "Browsing to http://$fqdn should redirect to HTTPS automatically with a valid TLS certificate from Let's Encrypt"
echo

exit 0
