FROM nginx:latest
COPY . /usr/share/nginx/html
RUN mv default.conf /etc/nginx
EXPOSE 80
CMD [ "nginx","-g","daemon off;" ] 