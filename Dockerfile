FROM ubuntu:14.04

# Set variable to supress warings when installing packages
ENV DEBIAN_FRONTEND noninteractive

# Update system
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y

# Install essentials
RUN apt-get install -y \
	software-properties-common \
	g++ \
	make \
	build-essential \
	automake \
	libtool \
	libevent-dev \
	pkg-config

# Install python
RUN apt-get install -y \
	python \
	python-dev

# Install pip
RUN apt-get install -y python-pip
#RUN apt-get install -y wget
#WORKDIR /tmp
#RUN wget http://python-distribute.org/distribute_setup.py
#RUN python distribute_setup.py
#RUN easy_install pip
#WORKDIR /

# Install nodejs
RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install -y nodejs	

# Install nginx
RUN apt-get install -y nginx
# Configuration for nginx. You can set the "projecto" to point to 192.168.33.10
# on your host machine.
ADD ./nginx/projecto /etc/nginx/sites-available/projecto
# Get nginx ready.
RUN ln -s /etc/nginx/sites-available/projecto /etc/nginx/sites-enabled/projecto
RUN service nginx restart

# Install riak
#RUN echo "deb http://apt.basho.com $(lsb_release -sc) main" \
#	> /etc/apt/sources.list.d/basho.list
#RUN apt-get update
#RUN apt-get install -y riak
#RUN riak start

# Install Java 7
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update -qq 
RUN apt-get install -y software-properties-common
RUN apt-add-repository ppa:webupd8team/java -y
RUN apt-get update -qq
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java7-installer

# Install Riak
ENV RIAK_VERSION 2.0.1-1
RUN apt-get install -y curl
RUN curl https://packagecloud.io/install/repositories/basho/riak/script.deb | bash
RUN apt-get install -y riak=${RIAK_VERSION}
RUN riak start

# Setup the Riak service
#RUN mkdir -p /etc/service/riak
#ADD bin/riak.sh /etc/service/riak/run

# Include projecto repository
ADD ./projecto /projecto

# Install dependencies
RUN apt-get install -y git subversion
WORKDIR /root
RUN pip install -r /projecto/production-requirements.txt

# Install node
WORKDIR /projecto
ENV PATH "/projecto/node_modules/.bin:$PATH"
RUN npm install

# run the unittests!
RUN echo "All setup complete! Now running teh tests!"
WORKDIR /projecto
RUN python -m unittest discover
RUN [ $? -eq 0 ] && \
	echo "Boom! all tests passed :D" \
	|| \
    echo "Uhoh. Something went wrong :("

# Define entry point command
ENTRYPOINT ["python", "server.py"]
