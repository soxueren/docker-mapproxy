#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM python:3.5-slim
MAINTAINER jxw<jxw@jxw>

#-------------Application Specific Stuff ----------------------------------------------------
RUN apt-get install --no-install-recommends --no-install-suggests -y \
    python-imaging \
    python-yaml \
    libproj0 \
    libgeos-dev \
    python-lxml \
    libgdal-dev \
    build-essential \
    python-dev \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    inotify-tools
                     
#------------mapproxy----------------------------------------------------------------------
RUN pip install \
	Shapely \
	Pillow \
	MapProxy \
	uwsgi 
                       
RUN apt-get clean
#-------------Application Specific Stuff ----------------------------------------------------

RUN mkdir /mapproxy
RUN mkdir /mapproxy/cache_data

ADD epsg /mapproxy/
ADD mapproxy.yaml /mapproxy/
ADD app.py /mapproxy/
ADD start.sh /start.sh

RUN chmod 0755 /start.sh

EXPOSE 8080 80 443
#USER www-data
# Now launch mappproxy in the foreground
# The script will create a simple config in /mapproxy
# if one does not exist. Typically you should mount 
# /mapproxy as a volume
CMD [./start.sh]
