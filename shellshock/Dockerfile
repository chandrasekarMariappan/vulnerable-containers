FROM vulnerable-centos:6
COPY rootfs .
RUN yum install -y httpd
EXPOSE 80 443
ENTRYPOINT ["/entrypoint.sh"]
