declareUpdate();
const uris = cts.uris().toArray();

uris.forEach(uri => {
  let doc = cts.doc(uri).toObject();
  
  if (doc["_source.message"]) {
    let jsonString = doc["_source.message"].replace("Completed request:", "").trim();
    doc["_source.message"] = JSON.parse(jsonString);
    xdmp.documentInsert(uri, doc);
  }
});


