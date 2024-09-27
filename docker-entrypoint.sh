#!/bin/sh
set -e

echo "Start Entrypoint ..."

echo "Add variables for Azure..."
# Add variables for Azure cli as ENV
AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}
AZURE_CLIENT_ID=${AZURE_CLIENT_ID}
AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}
AZURE_TENANT_ID=${AZURE_TENANT_ID}
# Add variables for Azure as secret -> secrets are more preferred
[ -f /run/secrets/AZURE_SUBSCRIPTION_ID ] && export AZURE_SUBSCRIPTION_ID=${cat /run/secrets/AZURE_SUBSCRIPTION_ID}
[ -f /run/secrets/AZURE_CLIENT_ID ] && export AZURE_CLIENT_ID=${cat /run/secrets/AZURE_CLIENT_ID}
[ -f /run/secrets/AZURE_CLIENT_SECRET ] && export AZURE_CLIENT_SECRET=${cat /run/secrets/AZURE_CLIENT_SECRET}
[ -f /run/secrets/AZURE_TENANT_ID ] && export AZURE_TENANT_ID=${cat /run/secrets/AZURE_TENANT_ID}

# For Ansible AzureRM Inventory:
# https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_inventory.html#notes
# AZURE_SUBSCRIPTION_ID
# AZURE_CLIENT_ID
export AZURE_SECRET=${AZURE_CLIENT_SECRET}
export AZURE_TENANT=${AZURE_TENANT_ID}

# Check if i can login to azure cli
if [ -n "${AZURE_CLIENT_ID}"  ] && [ -n "${AZURE_CLIENT_SECRET}"  ] && [ -n "${AZURE_TENANT_ID}"  ] 
then
    echo
    echo "Login to Azure CLI..."
    az login --service-principal --username ${AZURE_CLIENT_ID} --password ${AZURE_CLIENT_SECRET} --tenant ${AZURE_TENANT_ID}
    az account get-access-token
    echo
else
    echo
    echo "I cannot login to azure cli because of missing of one or all of the ENV vars: AZURE_CLIENT_ID AZURE_CLIENT_SECRET AZURE_TENANT_ID"
    echo
fi

# Install requirements file if exists in ~/requirements.yml
echo "Check if additional galaxies must be installed from ~/requirements.yml or ~/ansible/requirements.yml"
[ -f ~/requirements.yml ] && ansible-galaxy install -r ~/requirements.yml
[ -f ~/ansible/requirements.yml ] && ansible-galaxy install -r ~/ansible/requirements.yml

# Start the following command:
echo "#####" # empty line
echo "Start with command '$@'"
echo "#####" # empty line

# Preventing ansible zombie processes. Tini kills zombies.
/sbin/tini -- $@
