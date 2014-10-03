#!/bin/bash

# Check if repository is present
[ ! -e ./projecto ] && {
	# If not clone it
	git clone https://github.com/shuhaowu/projecto.git
} || {
	# Else update
	(cd projecto && git pull)
}

# Download key
#curl http://apt.basho.com/gpg/basho.apt.key \
#	-o ./riak/gpg.key
#curl https://packagecloud.io/gpg.key \
#	-o ./riak/gpg.key

## Download riak installer
#[ ! -e ./riak/2.0.0-1.deb ] && {
#	curl -L "https://packagecloud.io/basho/riak/download?distro=trusty&filename=riak_2.0.0-1_amd64.deb" \
#		-o ./riak/2.0.0-1.deb
#}

# Build image
sudo docker build --rm -t docker-projecto .
