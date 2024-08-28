.PHONY:

container_build:
	docker build -t ghcr.io/8ear/docker-ansible-semaphore .

container_bash:
	docker run -ti --rm ghcr.io/8ear/docker-ansible-semaphore bash