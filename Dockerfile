# https://github.com/semaphoreui/semaphore/blob/develop/deployment/docker/server/Dockerfile
ARG SEMAPHORE_VERSION=v2.13.0-powershell7.5.0
FROM semaphoreui/semaphore:$SEMAPHORE_VERSION

# WORKDIR /home/semaphore
#ENV VIRTUAL_ENV="$ANSIBLE_VENV_PATH"
#ENV PATH="$ANSIBLE_VENV_PATH/bin:$PATH"

# Make me root to add packages
USER root

# Additional ENV
ENV AZURE_CLI_VENV_PATH="/opt/azure-cli/venv"

# Add system packages
# heimdal-dev python3-dev build-base openssl-dev libffi-dev cargo \
# https://stackoverflow.com/questions/47699304/how-to-create-a-dind-docker-image-with-azure-cli-on-alpine-linux
RUN apk add --no-cache -U --virtual=build python3-dev build-base openssl-dev libffi-dev cargo \
    # add krb5-dev to fix https://stackoverflow.com/questions/74854623/gssapi-docker-installation-issue-bin-sh-1-krb5-config-not-found
    # https://github.com/dotnet/dotnet-docker/issues/3844#issuecomment-1156181785
    ;apk add --no-cache -U krb5-dev icu \
    ;source ${VIRTUAL_ENV}/bin/activate \  
    ;apk upgrade --no-cache \
    ;pip3 pip3 install --upgrade pip ansible requests \
    ;pip3 install --no-cache-dir --prefer-binary \
    #;pip3 install \
       ansible-lint \
       # https://docs.ansible.com/ansible/latest/collections/microsoft/ad/ldap_inventory.html#requirements
       dnspython \
       #pyspnego>=0.8.0
       pyspnego \
       pyspnego[kerberos] \
       sansldap \
       dpapi-ng \
       # https://stackoverflow.com/questions/72819370/install-ms-graph-python-module
       msgraph-core \
    # https://galaxy.ansible.com/ui/repo/published/azure/azcollection/docs/?extIdCarryOver=true&sc_cid=701f2000001OH6uAAG
    ;ansible-galaxy collection install azure.azcollection --force \
    ;pip3 install -r /opt/semaphore/apps/ansible/9.4.0/venv/lib/python3.11/site-packages/ansible_collections/azure/azcollection/requirements-azure.txt \
    #; mkdir /etc/krb5.d \
    #; echo "includedir /etc/krb5.d" >> /etc/krb5.conf \
    #; chown -R semaphore:0 /opt/semaphore /home/semaphore /etc/krb5.d \
    # Additional VENV for Azure CLI because Ansible Azure Collection has a fixed Azure CLI which is not working, but we want to have both
    # https://www.freecodecamp.org/news/how-to-setup-virtual-environments-in-python/
    # https://medium.com/@mahesh_23s/workaround-to-run-aks-preview-cli-extension-on-linux-493d6d406549
    ;mkdir -p $AZURE_CLI_VENV_PATH \
    ;python -m venv $AZURE_CLI_VENV_PATH \
    ;source $AZURE_CLI_VENV_PATH/bin/activate \
    ;pip3 install --no-cache-dir --prefer-binary \
        # Install Azure CLI
       # https://github.com/Azure/azure-cli/issues/19591
       azure-cli \
    ; apk del build \
    ; rm -rf /var/cache/apk/*

# Go back to unprivileged user
USER 1001

# Add Ansible custom config
COPY config/ansible.cfg /etc/ansible/ansible.cfg
COPY play_ci_test_localhost.yml /home/semaphore/play_ci_test_localhost.yml

# To suppress info from tini that it do not run as id=0
ENV TINI_SUBREAPER=true

# Add additional python venv + user azure bin folder for azure CLI installations
ENV PATH="$VIRTUAL_ENV/bin:$AZURE_CLI_VENV_PATH/bin:/home/semaphore/.azure/bin:$PATH"

# # Preventing ansible zombie processes. Tini kills zombies.
# ENTRYPOINT ["/sbin/tini", "--"]
# CMD [ "/usr/local/bin/server-wrapper"]

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
