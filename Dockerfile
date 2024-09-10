# https://github.com/semaphoreui/semaphore/blob/develop/deployment/docker/server/Dockerfile
ARG SEMAPHORE_VERSION=v2.10.22
FROM semaphoreui/semaphore:$SEMAPHORE_VERSION

# WORKDIR /home/semaphore
#ENV VIRTUAL_ENV="$ANSIBLE_VENV_PATH"
#ENV PATH="$ANSIBLE_VENV_PATH/bin:$PATH"

# Make me root to add packages
USER root

# Add system packages
# heimdal-dev python3-dev build-base openssl-dev libffi-dev cargo \
RUN apk add --no-cache -U python3-dev build-base openssl-dev libffi-dev cargo krb5-dev \
    # add krb5-dev to fix https://stackoverflow.com/questions/74854623/gssapi-docker-installation-issue-bin-sh-1-krb5-config-not-found
    ; source ${VIRTUAL_ENV}/bin/activate \  
    ;pip3 install --upgrade pip \
    ;pip3 install -r /opt/semaphore/apps/ansible/9.4.0/venv/lib/python3.11/site-packages/ansible_collections/azure/azcollection/requirements-azure.txt \
    # Install Azure CLI
    # https://github.com/Azure/azure-cli/issues/19591
    ;pip3 install  \
       azure-cli \
       ansible-lint \
       # https://docs.ansible.com/ansible/latest/collections/microsoft/ad/ldap_inventory.html#requirements
       dnspython \
       #pyspnego>=0.8.0
       pyspnego \
       pyspnego[kerberos] \
       sansldap \
       dpapi-ng \
    ; chown -R semaphore:0 /opt/semaphore /home/semaphore \
    ; apk del python3-dev build-base openssl-dev libffi-dev cargo krb5-dev \
    ; rm -rf /var/cache/apk/*

# Go back to unprivileged user
USER 1001

# Add Ansible custom config
COPY config/ansible.cfg /etc/ansible/ansible.cfg
COPY play_ci_test_localhost.yml /home/semaphore/play_ci_test_localhost.yml

ENV TINI_SUBREAPER=true

# # Preventing ansible zombie processes. Tini kills zombies.
# ENTRYPOINT ["/sbin/tini", "--"]
# CMD [ "/usr/local/bin/server-wrapper"]

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
