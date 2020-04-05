# Description

A small project that spins up nginx containers based on either the latest version of ubuntu or centos.

# Requirements

The following was defined to created those nginx containers.

- A single packer template is to be used.
- That same packer template will be able to build centos:latest container or ubuntu:latest container with a single parameter.
- Any provisioner can be used to build the container installation
- SSL must be disabled
- Standard http port must be exposed.
- The container image must be built in the format `homework/nginx-OSNAME`
- After the containers images are built, they must be pushed out to a docker hub in format `<DockerHubUser>/OS-nginx`
- Finally, container must be instantiated with the directory mount on to the container directory. That directory much container an index html file with the words "Hello World". In addition, we should able to map any arbitrary available port to the container.

The following will be need to accomplish this:

- Installed version of packer
- Installed version of docker
- Installed version of either ansible, puppet, or any shell script
- A Docker Hub account.

# Implementation

We created `docker-nginx.json` that allows you to build with either `centos` or `ubuntu` by passing either os name as a parameter. There wasn't a need to pass `:latest` as it appears docker will allow you to download `osname:latest` by default.

We choose the `ansible-local` provisoner to configure the image. This does require use to install ansible on the container (via a simple shell script), which does increase the container image size, but it allow us to avoid having to install ssh and expose additional ports, which simplifies the build.

In addition, using `ansible-local` allow us to take advantage of well-tested and supported third party playbooks that automate the installation and configuration of any application. In this case, we picked the official Nginx ansible role from Ansible Galaxy, copied their example and was able to install nginx with a couple of parameter tweaks to meet requirements. The repo itself contains `ansible.cfg` and `requirements.yml` as a way to install the said role.

From here, it is mostly automating the build itself with scripts as well as ensuring that we can start up nginx. In the end, we were able to instantiated containers successfully:

```
rilindo@allmight docker-practice-nginx (cleanup)*$ docker run -d -v "$(pwd)"/test_html:/html -p 8888:80 homework/nginx-centos:latest
99a841cf7f4a69d9c42c90b5e2743b90446b60f1404cc1e304110889a3346952
rilindo@allmight docker-practice-nginx (cleanup)*$ curl localhost:8888
<html>
<body>
  <p>Hello, World!</p>
</body>
</html>
rilindo@allmight docker-practice-nginx (cleanup)*$ docker ps -a
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                  NAMES
99a841cf7f4a        homework/nginx-centos:latest   "/bin/sh -c /usr/loc…"   27 seconds ago      Up 26 seconds       0.0.0.0:8888->80/tcp   optimistic_swirles
rilindo@allmight docker-practice-nginx (cleanup)*$ docker stop optimistic_swirles
optimistic_swirles
rilindo@allmight docker-practice-nginx (cleanup)*$ docker rm optimistic_swirles
optimistic_swirles
rilindo@allmight docker-practice-nginx (cleanup)*$ docker run -d -v "$(pwd)"/test_html:/html -p 8888:80 homework/nginx-ubuntu:latest
59dd38abdd97718c23cef2785f8b0e9cff9b013c17108c6af5c0aa72baf87145
rilindo@allmight docker-practice-nginx (cleanup)*$ curl localhost:8888
<html>
<body>
  <p>Hello, World!</p>
</body>
</html>
rilindo@allmight docker-practice-nginx (cleanup)*$ docker ps -a
CONTAINER ID        IMAGE                          COMMAND                  CREATED             STATUS              PORTS                  NAMES
59dd38abdd97        homework/nginx-ubuntu:latest   "/bin/sh -c /usr/loc…"   17 seconds ago      Up 15 seconds       0.0.0.0:8888->80/tcp   magical_clarke
rilindo@allmight docker-practice-nginx (cleanup)*$ docker stop magical_clarke
magical_clarke
rilindo@allmight docker-practice-nginx (cleanup)*$ docker rm magical_clarke
magical_clarke
rilindo@allmight docker-practice-nginx (cleanup)*$

```

# File and Directory Descriptions

The following are the description of files used to implement this project.

- `ansible.cfg` - used to allow us to install the role on this repo with out specifying the path.
- `build.sh` - a wrapper script used to  confirm location of required binaries, verify the template and playbook, build the images and finally push out the images to docker hub.
- `docker-nginx.json` - packer template used to build the images.
- `entrypoint.sh` - a shell script used to launch nginx with the container.
- `install_ansible.sh` - a simple shell script to bootstrap ansible within the container.
- `nginx.yml` - an ansible playbook based on the third example [here](https://galaxy.ansible.com/nginxinc/nginx), with a single task to created the `/html` directory. The only changes made (aside from some initial configuration to allow the playbook to run within the container) are disabling the `ssl` port, disabling startup with `nginx_start`, setting `html_file_location`. Notably, I did not mean to leave `autoindex` `false`, but the index page appear to come up anyway even with this setting, so I will leave it alone for now. :)
- `README.md` - what you are reading right now.
- `requirements.yml` - YAML template to install role into this repo.

The following are the description of directories used to implement this project.

- `roles`: container the installed NGINX ansible role.
- `test_html`: a test folder that contain the `Hello, World!` index file.

# Testing

This was tested on a Mac Mini 2018 with Mac OS X Catalina 10.15.4 and Docker Desktop 2.2.5. Presumably, the containers should work on any Linux host running the most recent release of Docker.
