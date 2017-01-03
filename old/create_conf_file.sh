#!/bin/bash

cd /opt/graphite/conf
for f in *.conf.example; do cp "$f" "${f//.conf.example/.conf}"; done
for f in *.wsgi.example; do cp "$f" "${f//.wsgi.example/.wsgi}"; done
ln -s /opt/graphite/conf/graphite.wsgi /opt/graphite/webapp/wsgi.py
