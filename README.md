# Objective

A single packer template that uses
- the docker builder
- the ansible, puppet, or shell provisioners to bake a linux container into a generic nginx server.

The packer template should be able to successfully turn the following into a working nginx server.
- ubuntu:latest
- centos:latest generic docker container

The packer template should be able to use an operating system depending on
- a variable passed in from the packer build command line.


After a successful build, it should push that docker image to a docker hub account creating
- <yourDockerHubUser>/ubuntu-nginx
- <yourDockerHubUser>/centos-nginx container.

both containers need to be able to serve an index.html hello world text document via the following command:
```
docker run -v /tmp/test_html:/html -p 8888:80 homework/nginx-ubuntu:latest
```

SSL:
- is not required for this homework
- should be disabled in your nginx config files.

Please have your code committed to GitHub by Sunday evening.

Thanks so much for your time!
