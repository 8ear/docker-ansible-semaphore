# docker-ansible-semaphore
Docker Container for Ansible with base image from [Ansible Semaphore](https://github.com/semaphoreui/semaphore/tree/develop/deployment/docker).
This container is used for Ansible, but it contains also opentofu and the full ansible semaphore web UI.

I modified the container, so that Azure dependencies are installed during the build and that default `ansible.cfg` is replaced with the one from this repo.

# Usage

`docker-compose .yml` / `compose.yml` example:
````docker-compose
---
volumes:
  semaphore_data:
  semaphore_config
  semaphore_tmp_config

secrets:
  AZURE_SECRET:
  file: ./SECRET_AZURE_SECRET.txt

services:
  app:
    image: ghcr.io/8ear/docker-ansible-semaphore
    environment:
      - SEMAPHORE_x see https://github.com/semaphoreui/semaphore/blob/develop/deployment/compose/server/base.yml and https://docs.semaphoreui.com/administration-guide/installation#docker
      - AZURE_SUBSCRIPTION_ID=
      - AZURE_CLIENT_ID=
      - AZURE_TENANT_ID=
      - INVENTORY_AD_x see Ansible Microsoft AD Inventory stuff
    volumes:
    - semaphore_data:/var/lib/semaphore
    - semaphore_config:/etc/semaphore
    - semaphore_tmp_config:/tmp/semaphore
    - <PATH to requirements.yml>:/home/semaphore/requirements.yml:ro
  secrets:
    - AZURE_SECRET
  expose:
    - 3000
````
## Azure CLI `az`
To use az extensions, they must be enabled first:
Show az extensions: `az extension list-available --output table`
Enable az extension: `az extension add --name subscription`
````


## Credits
This was not possible without the the people from Ansible Semaphore!
- https://github.com/semaphoreui/semaphore/tree/develop
