FROM ubuntu
RUN apt-get -y update && apt-get -y install nginx
COPY nginx.conf /etc/nginx/sites-available/default
RUN mkdir /app/
RUN useradd nginx && usermod -u 1001 nginx && groupmod -g 1001 nginx
RUN chown -R nginx:nginx /app
RUN chmod -R 755 /app
ADD homework.html app/index.html
EXPOSE 8000/tcp
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
