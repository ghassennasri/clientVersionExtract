// Assume 'content' is the parameter of the transform function which holds the content.value
function parseMessageTransform(content, context) {
 var docType = xdmp.nodeKind(content.value);
  if (xdmp.nodeKind(content.value) == 'document' &&
      content.value.documentFormat == 'JSON') {
    // Convert input to mutable object and add new property
    var newDoc = content.value.toObject();
      if (newDoc["_source.message"] && typeof newDoc["_source.message"] === "string") {
    // Extract the JSON string from the _source.message property
    let message = newDoc["_source.message"];
    if (message.startsWith("Completed request:")) {
      let jsonString = message.replace("Completed request:", "").trim();
      
      try {
        // Parse the extracted JSON string and update the _source.message property
        newDoc["_source.message"] = JSON.parse(jsonString);
      } catch (e) {
        // If parsing fails, log the error
        xdmp.log("Error parsing JSON from _source.message. Error: " + e.toString());
      }
    }
  }
    // Convert result back into a document
    content.value = xdmp.unquote(xdmp.quote(newDoc));
  }
  return content;
 
 
 
  
};

// Export the module
exports.transform = parseMessageTransform;
