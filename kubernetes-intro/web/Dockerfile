FROM ubuntu:latest
RUN  mkdir /app/
RUN yum -y install epel-release
RUN yum -y install nginx
RUN usermod -u 1001 nginx && groupmod -g 1001 nginx
ADD nginx.conf /etc/nginx/nginx.conf
EXPOSE 8000
CMD ["nginx", "-g", "daemon off;"]