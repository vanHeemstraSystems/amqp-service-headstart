amqp-service-headstart
# AMQP Service - Headstart

- Based on "Docker Coins" at https://github.com/vanHeemstraSystems/dockercoins-headstart
- Based on "Running a Ballerina Service in a Docker Container" at https://ballerina.io/1.2/learn/deployment/docker/

## 100 - Prerequisites

- Ballerina, see https://ballerina.io/1.2/learn/installing-ballerina/ or https://github.com/vanHeemstraSystems/ballerina-headstart/blob/main/100/200/300/README.md
- Docker Engine
- Docker Compose
- [OPTIONAL] Gradle, see https://www.vultr.com/docs/how-to-install-gradle-on-centos-7
- [OPTIONAL] Kubectl

## 200 - Install kubectl [OPTIONAL]

```
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
$ chmod +x ./kubectl
$ sudo mv ./kubectl /usr/local/bin/kubectl
$ kubectl version --client
```

## 300 - Install Ballerina module Code to Cloud (c2c) [OPTIONAL]

See https://github.com/ballerina-platform/module-ballerina-c2c

1. Download and install JDK 11, see https://phoenixnap.com/kb/install-java-on-centos
2. Export github personal access token & user name as environment variables, see https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token.
```
    export packagePAT=<Token>
    export packageUser=<username>
```
3. (optional) Specify the Java home path for JDK 11 ie, see https://computingforgeeks.com/how-to-set-java_home-on-centos-fedora-rhel/;
```
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.11.0.9-1.el7_9.x86_64
```

In short, add the following to your ```.bash_profile```:

```
PATH=$PATH:$HOME/.local/bin:$HOME/bin

PATH=$PATH:/opt/gradle/gradle-3.4.1/bin

export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar

export packagePAT=*****SECRET*****
export packageUser=willem-vanheemstrasystems
```

4. Install Docker, see https://github.com/vanHeemstraSystems/docker-quick-start-headstart
5. Get a clone or download the source from this repository: [OPTIONAL]
```
git clone https://github.com/ballerina-platform/module-ballerina-c2c
```
7. Run the Gradle command ```./gradlew build``` from within the module-ballerina-c2c directory. ***Note***: we use the command for a ***local*** Gradle, not ```gradle build``` [OPTIONAL]
8. Copy ```c2c-extension/build/c2c-extension-***.jar``` file to ```<BALLERINA_HOME>/bre/lib``` directory. [OPTIONAL]
9. Copy ```c2c-ballerina/build/target/c2c-ballerina-zip/bala/ballerina/cloud``` directory to ```<BALLERINA_HOME>/repo/bala/ballerina``` directory. [OPTIONAL]
10. Copy ```c2c-ballerina/build/target/c2c-ballerina-zip/cache/ballerina/cloud``` directory to ```<BALLERINA_HOME>/repo/cache/ballerina``` directory. [OPTIONAL]

## 400 - Containers

### 100 - WebUI

### 200 - Consumer

We already have the project 'consumer' created, but if starting from fresh use the following command to create a new ballerina project (here: consumer):

```
$ cd containers/amqp-service/
$ bal new consumer
Created new Ballerina package 'consumer' at consumer.
```
Look inside:
```
$ cd consumer
$ ls -la
.
..
Ballerina.toml
.gitignore
main.bal
```
The directory structure is now as follows:
```
containers/amqp-service/
  consumer (auto-created)
    Ballerina.toml (auto-created)
    .gitignore (auto-created)
    main.bal (auto-created)
```
In order to ***initialize*** the project, we will have to execute the following command from the main folder.
```
$ cd consumer
$ bal init
ballerina: Directory is already a ballerina project
```
To also create our first module 'http', if starting from fresh use the following Ballerina command for creating a new ***module*** (here: ```http```):
```
$ cd consumer
$ bal add http
Added new ballerina module at 'modules/http'
```
Look inside:
```
$ ls -la
    Ballerina.toml (auto-created)
    .gitignore (auto-created)
    main.bal (auto-created)
    modules
      http
```
The directories now look as follows:
```
containers/amqp-service/
  consumer (auto-created)
    Ballerina.toml (auto-created)
    .gitignore (auto-created)
    main.bal (auto-created)
    modules (auto-created)
      http (auto-created)
        http.bal (auto-created)
```

For making use of containerization add the file 'Cloud.toml' to the directory with the following content:

```
# Before you build the package, we are going to override some of the default values taken by the compiler,

[container.image]
repository="com.acme.consumer"
name="consumer"
tag="v0.1.0"
```
containers/amqp-service/consumer/Cloud.toml

Add a build option to ```Ballerina.toml``` to specify if it needs to create Kubernetes (incl. Docker) artifacts (```cloud = "k8s"```) or Docker artifacts only (```cloud = "docker"```):

```
[build-options]
observabilityIncluded = true
cloud = "docker"
```
containers/amqp-service/consumer/Ballerina.toml

***Note***: We have chosen to use ```cloud = "docker"``` instead of ```cloud = "k8s"``` in ```Ballerina.toml```, because we have not installed kubectl.


***Tip***: See instructions on how to use Docker / Kubernetes with Ballerina at https://ballerina.io/learn/user-guide/deployment/code-to-cloud/

***Tip***: See an overview of the Standard Library of Ballerina at https://github.com/ballerina-platform/ballerina-standard-library

Our service will be called ```http.bal``` and will look as follows when first generated:

```
import ballerina/io;

public function hello() {
    io:println("Hello World!");
}
```
containers/amqp-service/consumer/modules/http/http.bal

We will modify the ```http.bal``` to the content as follows (note: EP = EndPoint):

```
import ballerina/http;
import ballerina/log;
import ballerina/docker; ## not ballerinax/docker

@docker:Expose {}
listener http:Listener consumerEP = new(9091);
map<json> messagesMap = {};

@docker:Config {
  Registry:"com.acme.consumer", name:"consumer", tag:"v1.0"
}

@http:ServiceConfig {
  basePath: "/consumer"
}

service messages on consumerEP {
  @http:ResourceConfig {
    methods: ["GET"], path: "/consumer/{messageId}"
  }

  resource function getById(http:Caller caller, http:Request req, string messageId) {
    json? payload = messagesMap[messageId];
    http:Response response = new;
    if (payload == null) {
      response.statusCode = 404;
      payload = "Item Not Found";
    }
    response.setJsonPayload(untaint payload);
    var result = caller->respond(response);
    if (result is error) {
      log:printError("Error sending response", err = result);
    }
  }
}
```
containers/amqp-service/consumer/modules/http/http.bal

We import the Ballerina utility libraries: docker, http and log. Using this code as a reference, let's focus on the key parts of this service:

- We configure our service to listen to the requests arriving at port 9091 within the context of the /consumer URL.

- We link a resource to the service: one that listens for the GET method which expects an identifier in the URL.

- The GET method will return response code 200 and the object associated with the identifier posted in the URL, or 404 if the object is not found.


In order to create an image linked to our service that is handled by Docker we will need to keep the following aspects of the code above in mind:

- We have indicated the service port to expose to the outside world.

- We have included the configuration of the image to be created.

In order to create the image we will need to execute the following command from ***outside*** the project directory (here: consumer):

```
$ ls -la
consumer
$ bal build consumer
Compiling source
  <user>/consumer:0.1.0
  
Generating executable
  consumer/target/bin/consumer.jar
```

***WARNING***: Above command fails:

```
$ bal build consumer
Compiling source
        cloud_user/consumer:0.1.0
Generating executable
Generating artifacts...
error [k8s plugin]: module [cloud_user/consumer:0.1.0] unable to build docker image: could not build image: failed to export image: failed to create image: failed to get layer sha256:18cf22e3c1d3ceb25b360fe0642ebf8b5f3ed32b2bfaaadbc1ae18e6dc3ef8f3: layer does not exist
        consumer/target/bin/consumer.jar
```

***RESOLUTION***: Set the following environment variable ***before*** executing the command.

```
$ export CI_BUILD=true
```

Try again:

```
$ bal build consumer
```

If successfull, you will see after a while:

```
Compiling source
        cloud_user/consumer:0.1.0

Generating executable

Generating artifacts...

        @kubernetes:Docker                       - complete 2/2 

        Execute the below command to run the generated docker image: 
        docker run -d -p 9090:9090 com.acme.consumer/consumer:v0.1.0

        consumer/target/bin/consumer.jar
```

Optionally, check for any running Docker containers:

```
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

Now execute the command as prompted in previous outcome:

```
$ docker run -d -p 9090:9090 com.acme.consumer/consumer:v0.1.0
7a6f6816ff91274e085338172e09501c90fc53180f7d95981accbebaef4388db
docker: Error response from daemon: driver failed programming external connectivity on endpoint romantic_khorana (c0a1fc8378969108ced8c743da7166f4e4b77d67aba74c90541acadaa89b1f6f): Error starting userland proxy: listen tcp4 0.0.0.0:9090: bind: address already in use.
```

***OOOPS***: Check what other process may already be running on port 9090

```
$ sudo netstat -lnp | grep 9090
[sudo] password for cloud_user: 
tcp6       0      0 :::9090                 :::*                    LISTEN      1/systemd
```

Retry Docker run with a different Docker host port (now ***9092***) as the 9090 is already in use by the Docker host:

```
$ docker run -d -p 9092:9090 com.acme.consumer/consumer:v0.1.0
70d9056d5b667129d3c74f67563f527be51cb2d024e93269538babafd59b8e46
```

Check running Docker containers again:

```
$ docker ps
CONTAINER ID   IMAGE                               COMMAND                  CREATED         STATUS         PORTS                                       NAMES
70d9056d5b66   com.acme.consumer/consumer:v0.1.0   "/bin/sh -c 'java -X???"   5 seconds ago   Up 4 seconds   0.0.0.0:9092->9090/tcp, :::9092->9090/tcp   charming_goodall
```

SUCCESS!!

See if the container works as expected (replaced ```localhost``` by Public IPv4 ```18.133.141.101``` for server on A Cloud Guru):

```
$ curl http://18.133.141.101:9092/../..

```

More ...







***TO DO***: Have a look at working examples at https://github.com/ballerina-platform/ballerina-dev-website/blob/master/learn/user-guide/deployment/code-to-cloud/code-to-cloud-samples.md

***Note***: If not already in existence an new project sub-directory called ```target``` is created inside of which the executable is stored (```bin/consumer.jar```).

And we can start our service thanks to Docker using the following command:

```$ docker run -d -p 9091:9091 com.acme.consumer/consumer:v1.0```

***Note***: Docker needs to have been installed for the above command to succeed.


more ...

### 300 - Publisher

We already have the project 'publisher' created, but if starting from fresh use the following command to create a new ballerina project (here: publisher):

```
$ cd containers/amqp-service/
$ bal new publisher
Created new Ballerina package 'publisher' at publisher.
```
Look inside:
```
$ cd publisher
$ ls -la
.
..
Ballerina.toml
.gitignore
main.bal
```
The directory structure is now as follows:
```
containers/amqp-service/
  publisher (auto-created)
    Ballerina.toml (auto-created)
    .gitignore (auto-created)
    main.bal (auto-created)
```
In order to ***initialize*** the project, we will have to execute the following command from the main folder.
```
$ cd publisher
$ bal init
ballerina: Directory is already a ballerina project
```
To also create our first module 'http', if starting from fresh use the following Ballerina command for creating a new ***module*** (here: ```http```):
```
$ cd publisher
$ bal add http
Added new ballerina module at 'modules/http'
```
Look inside:
```
$ ls -la
    Ballerina.toml (auto-created)
    .gitignore (auto-created)
    main.bal (auto-created)
    modules
      http
```
The directories now look as follows:
```
containers/amqp-service/
  publisher (auto-created)
    Ballerina.toml (auto-created)
    .gitignore (auto-created)
    main.bal (auto-created)
    modules (auto-created)
      http (auto-created)
        http.bal (auto-created)
```

For making use of containerization add the file 'Cloud.toml' to the directory with the following content:

```
# Before you build the package, we are going to override some of the default values taken by the compiler,

[container.image]
repository="com.acme.publisher"
name="publisher"
tag="v0.1.0"
```
containers/amqp-service/publisher/Cloud.toml

Add a build option to ```Ballerina.toml``` to specify if it needs to create Kubernetes (incl. Docker) artifacts (```cloud = "k8s"```) or Docker artifacts only (```cloud = "docker"```):

```
[build-options]
observabilityIncluded = true
cloud = "docker"
```
containers/amqp-service/consumer/Ballerina.toml

***Note***: We have chosen to use ```cloud = "docker"``` instead of ```cloud = "k8s"``` in ```Ballerina.toml```, because we have not installed kubectl.


***Tip***: See instructions on how to use Docker / Kubernetes with Ballerina at https://ballerina.io/learn/user-guide/deployment/code-to-cloud/

***Tip***: See an overview of the Standard Library of Ballerina at https://github.com/ballerina-platform/ballerina-standard-library

Our service will be called ```http.bal``` and will look as follows when first generated:

```
import ballerina/io;

public function hello() {
    io:println("Hello World!");
}
```
containers/amqp-service/publisher/modules/http/http.bal

We will modify the ```http.bal``` to the content as follows (note: EP = EndPoint):

```
import ballerina/http;
import ballerina/log;
import ballerina/docker; ## not ballerinax/docker

@docker:Expose {}
listener http:Listener publisherEP = new(9091);
map<json> messagesMap = {};

@docker:Config {
  Registry:"com.acme.publisher", name:"publisher", tag:"v1.0"
}

@http:ServiceConfig {
  basePath: "/publisher"
}

service messages on publisherEP { 
  @http:ResourceConfig {
    methods: ["POST"], path: "/publisher"
  }

  resource function addMessage(http:Caller caller, http:Request req) {
    http:Response response = new;
    var publisherReq = req.getJsonPayload();
    if (publisherReq is json) {
      string messageId = publisherReq.message.id.toString();
      messagesMap[messageId] = publisherReq;
      response.statusCode = 201;
      response.setHeader("Location", "http://localhost:9091/publisher/message/" + messageId);
    } else {
      response.statusCode = 400;
      response.setPayload("Invalid payload received");
    }
    var result = caller->respond(response);
    if (result is error) {
      log:printError("Error sending response", err = result);
    }
  }
}
```
containers/amqp-service/publisher/modules/http/http.bal

We import the Ballerina utility libraries: docker, http and log. Using this code as a reference, let's focus on the key parts of this service:

- We configure our service to listen to the requests arriving at port 9091 within the context of the /publisher URL.

- We link a resource to the service: one that listens for the POST method, which expects a JSON object as a message.

- The POST method will store the JSON object in a map in the internal memory and respond 201 and a header containing the URL of our service if we want to retrieve the stored message.

In order to create the image we will need to execute the following command from ***outside*** the project directory (here: publisher):

```
$ ls -la
publisher
$ bal build publisher
Compiling source
  <user>/publisher:0.1.0
  
Generating executable
  publisher/target/bin/publisher.jar
```

***Note***: If not already in existence an new project sub-directory called ```target``` is created inside of which the executable is stored (```bin/publisher.jar```).

And we can start our service thanks to Docker using the following command:

```$ docker run -d -p 9091:9091 com.acme.publisher/publisher:v1.0```

***Note***: Docker needs to have been installed for the above command to succeed.



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
 ????????? docker
 ???   ????????? Dockerfile
 ????????? service_docker.bal
 ????????? service_docker.jar

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
32461676d3c2  service_docker:latest  "/bin/sh -c 'java -j???"   About a minute ago   Up About a minute 0.0.0.0:9090->9090/tcp    lucid_turing
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
