#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM python:2.7.12
MAINTAINER Tim Sutton<tim@kartoza.com>

# Use local cached debs from host (saves your bandwidth!)
# Change ip below to that of your apt-cacher-ng host
# Or comment this line out if you do not with to use caching

ADD 71-apt-cacher-ng /etc/apt/apt.conf.d/71-apt-cacher-ng

ENV APT_SRC "http://mirrors.aliyun.com/debian/"
RUN set -x \
    && mv /etc/apt/sources.list /etc/apt/sources.list.backup \
    && echo "deb ${APT_SRC} jessie main non-free contrib\r\ndeb ${APT_SRC} jessie-proposed-updates main non-free contrib\r\ndeb-src ${APT_SRC} jessie main non-free contrib\r\ndeb-src ${APT_SRC} jessie-proposed-updates main non-free contrib" > /etc/apt/sources.list \
    && apt-get update

RUN apt-get -y install python-imaging python-yaml libproj0

ADD ez_setup.py /ez_setup.py

RUN python ez_setup.py

RUN easy_install mapproxy

#-------------Application Specific Stuff ----------------------------------------------------

EXPOSE 8080

ADD start.sh /start.sh
RUN chmod 0755 /start.sh

#USER www-data
# Now launch mappproxy in the foreground
# The script will create a simple config in /mapproxy
# if one does not exist. Typically you should mount 
# /mapproxy as a volume
CMD /start.sh
