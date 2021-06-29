amqp-service-headstart
# AMQP Service - Headstart

Based on "Docker Coins" at https://github.com/vanHeemstraSystems/dockercoins-headstart
Based on "Running a Ballerina Service in a Docker Container" at https://ballerina.io/1.2/learn/deployment/docker/


## 100 - Prerequisites

- Docker Engine
- Docker Compose

## 200 - Containers

### 100 - WebUI

### 200 - Service

Sample Source Code:

```
import ballerina/http;
import ballerina/docker;
 
@docker:Config {}
service hello on new http:Listener(9090){
 
  resource function sayHello(http:Caller caller,http:Request request) returns error? {
      check caller->respond("Hello World!");
  }
}
```
containers/amqp-service/service/sample.service.bal

Steps to Run:

1. Compile the service.bal

```
$ cp sample.service.bal service.bal
$ ballerina build service.bal
Compiling source
  service.bal
  
Generating executables
  service.jar
  
Generating docker artifacts...
  @docker        - complete 2/2
  
  Run the following command to start a Docker container:
  docker run -d -p 9090:9090 service:latest
```

The artifacts files below will be generated with the build process.

```
$ tree
 .
 ├── docker
 │   └── Dockerfile
 ├── service_docker.bal
 └── service_docker.jar

 1 directory, 3 files
```

The build process automatically generates a Dockerfile with the following content:

```
# Auto Generated Dockerfile
 FROM ballerina/jre8:v1

 LABEL maintainer="dev@ballerina.io"

 RUN addgroup troupe \
     && adduser -S -s /bin/bash -g 'ballerina' -G troupe -D ballerina \
     && apk add --update --no-cache bash \
     && chown -R ballerina:troupe /usr/bin/java \
     && rm -rf /var/cache/apk/*

 WORKDIR /home/ballerina

 COPY service_docker.jar /home/ballerina

 USER ballerina

 CMD java -jar service_docker.jar
```

2. Verify that the Docker image is created.



more ...
