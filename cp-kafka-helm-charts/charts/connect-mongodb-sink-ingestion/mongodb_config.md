{
  "name": "mongodb-sink",
  "config": {
    "connection.uri":"mongodb://mongo-standalone-mongodb.promenade.svc:27017",
    "topics": "Chatillon-Northbound",
    "database": "test",
    "collection": "Chatillon",
    "connector.class":"com.mongodb.kafka.connect.MongoSinkConnector"
    "max.batch.size":"", integer
    "max.num.retries":"", integer
    "retries.defer.timeout":"", milliseconds
    "rate.limiting.every.n":"", Number of processed batches that should trigger the rate limit. A value of 0 means no rate limiting.
    "rate.limiting.timeout":"", How long (in milliseconds) to wait before continuing to process data once the rate limit is reached.
    "topic.override.<topicName>.<propertyName>" Per-topic configurations that override the corresponding global and 
        default property settings. For example: topic.override.foo.collection=bar instructs the sink connector to store
            data from the foo topic in the bar collection.
    "tasks.max" The maximum number of tasks that should be created for this connector. The connector may create fewer
     tasks if it cannot handle the specified level of parallelism.
  }
}