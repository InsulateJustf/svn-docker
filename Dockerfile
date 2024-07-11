# Alpine Linux with s6 service management.
# Use linuxserver.io as base for their PUID/PGID support.
# 3.15 is the most recent build that still has php7 support.
# FROM ghcr.io/linuxserver/baseimage-alpine:3.15
FROM ghcr.io/linuxserver/baseimage-alpine:3.20

# Install Apache2 and other stuff needed to access svn via WebDav
# Install svn
# Installing utilities for SVNADMIN frontend
# Create required folders
# Create the authentication file for http access
# Getting SVNADMIN interface
RUN apk add --no-cache apache2 apache2-ctl apache2-utils apache2-webdav mod_dav_svn &&\
	apk add --no-cache subversion &&\
	apk add --no-cache wget unzip php82 php82-apache2 php82-session php82-json php82-ldap &&\
	apk add --no-cache php82-xml &&\	
	sed -i 's/;extension=ldap/extension=ldap/' /etc/php82/php.ini &&\
	mkdir -p /run/apache2/ &&\
	mkdir /home/svn/ &&\
	mkdir /etc/subversion &&\
	touch /etc/subversion/passwd &&\
    wget --no-check-certificate https://github.com/InsulateJustf/iF.SVNAdmin/archive/stable-1.6.3.zip &&\
	unzip stable-1.6.3.zip -d /opt &&\
	rm stable-1.6.3.zip &&\
	mv /opt/iF.SVNAdmin-stable-1.6.3 /opt/svnadmin &&\
	ln -s /opt/svnadmin /var/www/localhost/htdocs/svnadmin &&\
	chmod -R 777 /opt/svnadmin/data

# Solve a security issue (https://alpinelinux.org/posts/Docker-image-vulnerability-CVE-2019-5021.html)	
RUN sed -i -e 's/^root::/root:!:/' /etc/shadow

# Add services configurations
COPY root /

# Add SVNAuth file
ADD subversion-access-control /etc/subversion/subversion-access-control
RUN chmod a+w /etc/subversion/* && chmod a+w /home/svn

# Add WebDav configuration
ADD dav_svn.conf /etc/apache2/conf.d/dav_svn.conf

# Set HOME in non /root folder
ENV HOME /home

# Make Apache run as abc:abc for PUID/PGID support.
RUN sed -i -e 's/^User apache/User abc/; s/^Group apache/Group abc/' /etc/apache2/httpd.conf

# Expose ports for http and custom protocol access
EXPOSE 80 443 3690
