#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM python:3.5-slim
MAINTAINER jxw<jxw@jxw>

# 更换软件源
ENV APT_SRC "http://mirrors.aliyun.com/debian/"
RUN set -x \
    && mv /etc/apt/sources.list /etc/apt/sources.list.backup \
    && echo "deb ${APT_SRC} jessie main non-free contrib\r\ndeb ${APT_SRC} jessie-proposed-updates main non-free contrib\r\ndeb-src ${APT_SRC} jessie main non-free contrib\r\ndeb-src ${APT_SRC} jessie-proposed-updates main non-free contrib" > /etc/apt/sources.list \
    && apt-get update

# 设置时区 +0800
RUN set -x \ 
    && mv /etc/timezone /etc/timezone.backup \
    && echo "Asia/Shanghai" > /etc/timezone \
    && mv /etc/localtime /etc/localtime.backup \
    && cp -f /usr/share/zoneinfo/Asia/Chongqing /etc/localtime \
    && mv /etc/default/rcS /etc/default/rcS.backup \
    && echo "UTC=yes" > /etc/default/rcS

# 设置UTF8编码 //zh_CN,en_US
RUN set -x \
    && apt-get install -y --no-install-recommends locales \
    && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8 \
    && apt-get purge -y locales
ENV LANG zh_CN.utf8
ENV LC_ALL zh_CN.utf8

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
    libfreetype6-dev 
    
#----------nginx-------------------------------------------------------------------------- 
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 && \
    echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
						ca-certificates \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt \
						nginx-module-geoip \
						nginx-module-image-filter \
						nginx-module-perl \
						nginx-module-njs \
						gettext-base 
                        
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
ADD nginx.conf /etc/nginx/nginx.conf

RUN chmod 0755 /start.sh

EXPOSE 8080 80 443
#USER www-data
# Now launch mappproxy in the foreground
# The script will create a simple config in /mapproxy
# if one does not exist. Typically you should mount 
# /mapproxy as a volume
CMD [./start.sh]
