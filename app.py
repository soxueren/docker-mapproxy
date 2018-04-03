# WSGI module for use with Apache mod_wsgi or gunicorn

# # uncomment the following lines for logging
# # create a log.ini with `mapproxy-util create -t log-ini`
# from logging.config import fileConfig
# import os.path
# fileConfig(r'/mapproxy/log.ini', {'here': os.path.dirname(__file__)})
import os
os.environ["http_proxy"] = "http://10.22.0.29:8080"
from mapproxy.wsgiapp import make_wsgi_app
application = make_wsgi_app(r'/mapproxy/mapproxy.yaml')
