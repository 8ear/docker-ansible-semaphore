#!/bin/sh
set -e

echo "Start Entrypoint ..."

echo "Add variables for Azure..."
# Add variables for Azure as ENV
AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID}
AZURE_CLIENT_ID=${AZURE_CLIENT_ID}
AZURE_SECRET=${AZURE_SECRET}
AZURE_TENANT_ID=${AZURE_TENANT_ID}
# Add variables for Azure as secret -> secrets are more preferred
[ -f /run/secrets/AZURE_SUBSCRIPTION_ID ] && AZURE_SUBSCRIPTION_ID=${cat /run/secrets/AZURE_SUBSCRIPTION_ID}
[ -f /run/secrets/AZURE_CLIENT_ID ] && AZURE_CLIENT_ID=${cat /run/secrets/AZURE_CLIENT_ID}
[ -f /run/secrets/AZURE_SECRET ] && AZURE_SECRET=${cat /run/secrets/AZURE_SECRET}
[ -f /run/secrets/AZURE_TENANT_ID ] && AZURE_TENANT_ID=${cat /run/secrets/AZURE_TENANT_ID}


# Create Azure credential file
mkdir ~/.azure
cat << EOF > ~/.azure/credentials
[default]
subscription_id=${AZURE_SUBSCRIPTION_ID}
client_id=${AZURE_CLIENT_ID}
secret=${AZURE_SECRET}
tenant=${AZURE_TENANT_ID}
EOF


# Install requirements file if exists in ~/requirements.yml
echo "Check if additional galaxies must be installed from ~/requirements.yml"
[ -f ~/requirements.yml ] && ansible-galaxy install -r ~/requirements.yml

# Start the following command:
echo "#####" # empty line
echo "Start with command '$@'"
echo "#####" # empty line

# Preventing ansible zombie processes. Tini kills zombies.
/sbin/tini -- $@
