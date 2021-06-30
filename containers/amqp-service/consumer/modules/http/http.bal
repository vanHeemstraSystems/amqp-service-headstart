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
