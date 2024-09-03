.PHONY:

container_build:
	docker build -t ghcr.io/8ear/docker-ansible-semaphore .

container_bash:
	docker run -ti --rm ghcr.io/8ear/docker-ansible-semaphore bash

container_test: 
	docker run -ti --rm ghcr.io/8ear/docker-ansible-semaphore ansible-playbook play_ci_test_localhost.yml