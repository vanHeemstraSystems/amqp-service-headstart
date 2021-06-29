ARG IMAGE_REPOSITORY
FROM ${IMAGE_REPOSITORY}/node:4-slim

# See https://stackoverflow.com/questions/29261811/use-docker-compose-env-variable-in-dockerbuild-file
ARG PROXY_USER
ARG PROXY_PASSWORD
ARG PROXY_FQDN
ARG PROXY_PORT

#ENV HTTP_PROXY="http://${PROXY_USER}:${PROXY_PASSWORD}@${PROXY_FQDN}:${PROXY_PORT}"
#ENV HTTPS_PROXY="http://${PROXY_USER}:${PROXY_PASSWORD}@${PROXY_FQDN}:${PROXY_PORT}"

RUN npm install express
RUN npm install redis
COPY static/ /static/
COPY server.js /
CMD ["node", "server.js"]
EXPOSE 80
