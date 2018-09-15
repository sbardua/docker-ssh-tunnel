#!/bin/bash

# Create a resource group.
az group create --name tunnelingus --location westus2

# Create a virtual network.
az network vnet create --resource-group tunnelingus --name tunnelingus-vnet --subnet-name tunnelingus-subnet

# Create a random uuid for use as a DNS name and make sure it's valid.
# Needs to start with a letter so keep trying until we get a good one.
while true
do
    dnsname=$(uuidgen | tr [:upper:] [:lower:])
    [[ $dnsname =~ ^[a-z][a-z0-9-]{1,61}[a-z0-9]$ ]] && break 1
done

# Create a public IP address.
az network public-ip create --resource-group tunnelingus --name tunnelingus-ip --dns-name $dnsname

# Create a network security group.
az network nsg create --resource-group tunnelingus --name tunnelingus-nsg

# Create an inbound port rule for SSH.
az network nsg rule create \
  --resource-group tunnelingus \
  --nsg-name tunnelingus-nsg \
  --name ssh-inbound \
  --protocol tcp \
  --priority 1000 \
  --destination-port-range 22

# Create an inbound port rule for our tunnel.
az network nsg rule create \
  --resource-group tunnelingus \
  --nsg-name tunnelingus-nsg \
  --name tunnel-inbound \
  --protocol tcp \
  --priority 1010 \
  --destination-port-range 2222

# Create an inbound port rule for HTTP.
az network nsg rule create \
  --resource-group tunnelingus \
  --nsg-name tunnelingus-nsg \
  --name http-inbound \
  --protocol tcp \
  --priority 1020 \
  --destination-port-range 80

# Create an inbound port rule for HTTPS.
az network nsg rule create \
  --resource-group tunnelingus \
  --nsg-name tunnelingus-nsg \
  --name https-inbound \
  --protocol tcp \
  --priority 1030 \
  --destination-port-range 443

# Create a virtual network card and associate with public IP address and NSG.
az network nic create \
  --resource-group tunnelingus \
  --name tunnelingus-nic \
  --vnet-name tunnelingus-vnet \
  --subnet tunnelingus-subnet \
  --network-security-group tunnelingus-nsg \
  --public-ip-address tunnelingus-ip

# Create a new virtual machine, this creates SSH keys if not present.
az vm create \
  --resource-group tunnelingus \
  --name tunnelingus \
  --nics tunnelingus-nic \
  --image UbuntuLTS \
  --size Standard_B2s \
  --admin-username tunnelingus \
  --generate-ssh-keys

# Setup the VM.
az vm run-command invoke --resource-group tunnelingus --name tunnelingus --command-id RunShellScript --scripts @./setup-azure-vm.sh

exit 0
