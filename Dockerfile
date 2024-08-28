# https://github.com/semaphoreui/semaphore/blob/develop/deployment/docker/server/Dockerfile
ARG SEMAPHORE_VERSION=v2.10.21
FROM semaphoreui/semaphore:$SEMAPHORE_VERSION

# WORKDIR /home/semaphore
#ENV VIRTUAL_ENV="$ANSIBLE_VENV_PATH"
#ENV PATH="$ANSIBLE_VENV_PATH/bin:$PATH"

# Make me root to add packages
USER root

# Add system packages
# heimdal-dev python3-dev build-base openssl-dev libffi-dev cargo \
RUN apk add --no-cache -U python3-dev build-base openssl-dev libffi-dev cargo \
    ; source ${VIRTUAL_ENV}/bin/activate \  
    ;pip3 install -r /opt/semaphore/apps/ansible/9.4.0/venv/lib/python3.11/site-packages/ansible_collections/azure/azcollection/requirements-azure.txt \
    # ;pip3 install --upgrade \
    #     ansible-lint \
    #     # https://docs.ansible.com/ansible/latest/collections/microsoft/ad/ldap_inventory.html#requirements
    #     dnspython \
    #     #pyspnego>=0.8.0
    #     pyspnego \
    #     pyspnego[kerberos] \
    #     sansldap \
    #     dpapi-ng \
    ; chown -R semaphore:0 /opt/semaphore /home/semaphore \
    ; apk del python3-dev build-base openssl-dev libffi-dev cargo \
    ; rm -rf /var/cache/apk/*

# Go back to unprivileged user
USER 1001

# # Add galaxies and roles
COPY requirements.yml /home/semaphore/requirements.yml

# Add Ansible custom config
COPY config/ansible.cfg /etc/ansible/ansible.cfg

# # Preventing ansible zombie processes. Tini kills zombies.
# ENTRYPOINT ["/sbin/tini", "--"]
# CMD [ "/usr/local/bin/server-wrapper"]

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]
