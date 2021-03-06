FROM ubuntu:xenial
MAINTAINER Jose Luis Rivero <jrivero@osrfoundation.org>

# setup environment
ENV LANG C
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
ENV DEBFULLNAME "TRI builder"
ENV DEBEMAIL "tri-build@tri.org"
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial multiverse" \
                                                         >> /etc/apt/sources.list && \
      echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse" \
                                                         >> /etc/apt/sources.list && \
      echo "deb http://archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse" && \
                                                         >> /etc/apt/sources.list
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-drake xenial main" >\
                                                /etc/apt/sources.list.d/osrf.drake.list

RUN apt-get update && apt-get install -y build-essential \
                   dirmngr         \
                   cmake           \
                   debhelper       \
                   mesa-utils      \
                   cppcheck        \
                   xsltproc        \
                   python-lxml     \
                   python-psutil   \
                   python          \
                   bc              \
                   netcat-openbsd  \
                   gnupg2          \
                   net-tools       \
                   locales         \
		   devscripts      \
   		   ubuntu-dev-tools\
  		   debhelper       \
  		   wget            \
 		   ca-certificates \
		   equivs          \
  		   git             \
  		   git-buildpackage \
 		   autopkgtest  && apt-get clean  && rm -rf /var/lib/apt/lists/*

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D2486D2DD83DB69272AFE98867170598AF249743
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add -
RUN echo "en_GB.utf8 UTF-8" >> /etc/locale.gen
RUN locale-gen en_GB.utf8
ENV LC_ALL en_GB.utf8
ENV LANG en_GB.utf8
ENV LANGUAGE en_GB
ENV RUNLEVEL 1
COPY builder builder
RUN chmod +x builder/release-new-snapshot.bash
