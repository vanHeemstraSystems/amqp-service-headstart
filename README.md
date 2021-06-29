amqp-service-headstart
# AMQP Service - Headstart

Based on "Docker Coins" at https://github.com/vanHeemstraSystems/dockercoins-headstart
Based on "Running a Ballerina Service in a Docker Container" at https://ballerina.io/1.2/learn/deployment/docker/


## 100 - Prerequisites

- Ballerina, see https://ballerina.io/1.2/learn/installing-ballerina/ or https://github.com/vanHeemstraSystems/ballerina-headstart/blob/main/100/200/300/README.md
- Docker Engine
- Docker Compose

## 200 - Containers

### 100 - WebUI

### 200 - Consumer

We already have the project 'consumer' created, but if starting from fresh use the following command to create a new ballerina project (here: consumer):

```
$ cd containers/amqp-service/
$ bal new consumer
Created new Ballerina package 'consumer' at consumer.
```

```
$ cd consumer
$ ls -la
.
..
Ballerina.toml
.gitignore
main.bal
```

more ...

### 300 - Publisher

We already have the project 'publisher' created, but if starting from fresh use the following command to create a new ballerina project (here: publisher):

```
$ cd containers/amqp-service/
$ bal new publisher
Created new Ballerina package 'publisher' at publisher.
```

```
$ cd consumer
$ ls -la
.
..
Ballerina.toml
.gitignore
main.bal
```

more ...

### 400 - Service = PENDING

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
$ bal build service.bal
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

```
$ docker images
 REPOSITORY          TAG         IMAGE ID            CREATED             SIZE
 service_docker      latest      e48123737a65        7 minutes ago       134MB
```

Since the annotation is not configured to have a custom Docker image name and tag, the build process will create a Docker image with the default values: the file name of the generated .jar file with the ```latest``` tag (e.g., ```service_docker:latest```).

3. Run the Docker image as a container (use the below command printed in step 1).

```
$ docker run -d -p 9090:9090 hello_world_docker:latest
32461676d3c22848088390483a414e5b1d11a7a73c2296eccb18e6c9f27c41c0
```

4. Verify that the Docker container is running.

```
$ docker ps
CONTAINER ID  IMAGE    		            COMMAND    	             CREATED              STATUS            PORTS                     NAMES
32461676d3c2  service_docker:latest  "/bin/sh -c 'java -j…"   About a minute ago   Up About a minute 0.0.0.0:9090->9090/tcp    lucid_turing
```

5. Access the service with the cURL command.

```
$ curl http://localhost:9090/service/sayHello           
Hello World!
```

6. Clean up the used artifacts.

```
Stop / kill running docker container
 > docker kill 32461676d3c2
 32461676d3c2

 Remove docker container files
 > docker em 32461676d3c2

 Remove docker image
 > docker rmi e48123737a65
```

Creating a Custom Ballerina Docker Image ...

more ...
