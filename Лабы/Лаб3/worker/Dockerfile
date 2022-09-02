FROM nginx:alpine

ARG WORKER_ID

RUN echo "WORKER $WORKER_ID" > /usr/share/nginx/html/index.html

EXPOSE 80