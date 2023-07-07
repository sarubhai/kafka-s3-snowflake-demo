topic_name='customers'
rest_proxy='http://127.0.0.1:8082'
schema_registry='http://127.0.0.1:8081'
kafka_connect='http://127.0.0.1:8083'


# TEST ALL SERVICES ARE UP, BEFORE PROCEEDING FURTHER
curl -s -k -X GET ${rest_proxy}/v3/clusters | jq
curl -s -k -X GET ${schema_registry}/subjects | jq
curl -s -k -X GET ${kafka_connect}/connector-plugins | jq


cluster_id=`curl -s -k -X GET ${rest_proxy}/v3/clusters | jq -r '.data | .[0].cluster_id'`
curl -s -k -X GET ${rest_proxy}/topics | jq

curl -s -k -X POST -H "Content-Type: application/json" ${rest_proxy}/v3/clusters/${cluster_id}/topics \
  --data '{"topic_name": "'${topic_name}'", "partitions_count": 3, "replication_factor": 1, "configs": [{"name": "cleanup.policy", "value": "delete"},{"name": "retention.ms", "value": 86400000}]}' | jq

res=`curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema": "{\"type\": \"int\"}", "value_schema": "{\"type\":\"record\",\"name\":\"'${topic_name}'\",\"fields\":[{\"name\":\"customer_id\",\"type\":\"int\"},{\"name\":\"customer_name\",\"type\":\"string\"},{\"name\":\"balance\",\"type\":\"double\"}]}", "records": [{"key":1,"value":{"customer_id":1,"customer_name":"John Doe","balance":5100.50}}]}' | jq`

ksid=`echo $res | jq .key_schema_id`
vsid=`echo $res | jq .value_schema_id`

curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":2,"value":{"customer_id":2,"customer_name":"Tom Hanks","balance":197700.75}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":3,"value":{"customer_id":3,"customer_name":"Jane Doe","balance":2100}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":4,"value":{"customer_id":4,"customer_name":"John Smith","balance":7000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":5,"value":{"customer_id":5,"customer_name":"Harry Page","balance":6000.80}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":2,"value":{"customer_id":2,"customer_name":"Tom Hanks","balance":190000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":3,"value":{"customer_id":3,"customer_name":"Jane Doe","balance":2500}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"customer_id":6,"customer_name":"Yo Man","balance":5000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":7,"value":{"customer_id":7,"customer_name":"Sam","balance":1500}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":8,"value":{"customer_id":8,"customer_name":"Jam","balance":2300}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":9,"value":{"customer_id":9,"customer_name":"Ram","balance":5400}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":10,"value":{"customer_id":10,"customer_name":"Tam","balance":6000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"customer_id":6,"customer_name":"Yo Man","balance":6000}}]}'

curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":11,"value":{"customer_id":11,"customer_name":"Suzi","balance":3220}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":12,"value":{"customer_id":12,"customer_name":"Suji","balance":394567}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":13,"value":{"customer_id":13,"customer_name":"Sumi","balance":21578}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":14,"value":{"customer_id":14,"customer_name":"Susu","balance":3467}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":15,"value":{"customer_id":15,"customer_name":"Sani","balance":73927}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":16,"value":{"customer_id":16,"customer_name":"Sadi","balance":22745}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":17,"value":{"customer_id":17,"customer_name":"Sapi","balance":12834}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":18,"value":{"customer_id":18,"customer_name":"Badu","balance":229654}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":19,"value":{"customer_id":19,"customer_name":"Badi","balance":2223446}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":20,"value":{"customer_id":20,"customer_name":"Bagi","balance":74336}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"customer_id":6,"customer_name":"Yo Man","balance":7000}}]}'

curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":21,"value":{"customer_id":21,"customer_name":"Hill","balance":22266}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":22,"value":{"customer_id":22,"customer_name":"Holl","balance":3222}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":23,"value":{"customer_id":23,"customer_name":"Hall","balance":12344}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":24,"value":{"customer_id":24,"customer_name":"Hack","balance":2566}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":25,"value":{"customer_id":25,"customer_name":"Hot","balance":2345}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":26,"value":{"customer_id":26,"customer_name":"Pot","balance":24567}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":27,"value":{"customer_id":27,"customer_name":"Poll","balance":22455}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"customer_id":6,"customer_name":"Yo Man","balance":5000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"customer_id":6,"customer_name":"Yo Man","balance":4000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":28,"value":{"customer_id":28,"customer_name":"Dan","balance":3467}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":29,"value":{"customer_id":29,"customer_name":"Tan","balance":8390}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":30,"value":{"customer_id":30,"customer_name":"Zan","balance":2468}}]}'

curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":31,"value":{"customer_id":31,"customer_name":"Mani","balance":2267}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"customer_id":6,"customer_name":"Yo Man","balance":10000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":32,"value":{"customer_id":32,"customer_name":"Lila","balance":3456}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":33,"value":{"customer_id":33,"customer_name":"Lali","balance":9283}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":34,"value":{"customer_id":34,"customer_name":"Loko","balance":9173}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":35,"value":{"customer_id":35,"customer_name":"Poko","balance":9258}}]}'

curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":31}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":32}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":33}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":34}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":35}]}'


# brew install kcat
# kcat -b 0.0.0.0:9092 -t ${topic_name} -s avro -r 0.0.0.0:8081


tee ${topic_name}.json &>/dev/null <<EOF
{
    "name": "${topic_name}",
    "connector.class": "io.confluent.connect.s3.S3SinkConnector",
    "storage.class": "io.confluent.connect.s3.storage.S3Storage",
    "topics": "${topic_name}",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schemas.enable": "true",
    "key.converter.schema.registry.url": "http://schema-registry:8081",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter.schemas.enable": "true",
    "value.converter.schema.registry.url": "http://schema-registry:8081",
    "s3.bucket.name": "kafka-s3-sink-dl",
    "s3.region": "eu-central-1",
    "s3.object.tagging": "true",
    "topics.dir": "cdl",
    "format.class": "io.confluent.connect.s3.format.parquet.ParquetFormat",
    "partitioner.class": "io.confluent.connect.storage.partitioner.TimeBasedPartitioner",
    "path.format": "YYYY/MM/dd/HH/mm",
    "timestamp.extractor": "Record",
    "transforms": "kafkaMetaData,formatTs",
    "transforms.kafkaMetaData.type": "org.apache.kafka.connect.transforms.InsertField\$Value",
    "transforms.kafkaMetaData.offset.field": "kafka_offset",
    "transforms.kafkaMetaData.partition.field": "kafka_partition",
    "transforms.kafkaMetaData.timestamp.field": "kafka_timestamp",
    "transforms.formatTs.type": "org.apache.kafka.connect.transforms.TimestampConverter\$Value",
    "transforms.formatTs.format": "yyyy-MM-dd HH:mm:ss:SSS",
    "transforms.formatTs.target.type": "string",
    "transforms.formatTs.field": "message_ts",
    "behavior.on.null.values": "write",
    "store.kafka.keys": "true",
    "keys.format.class": "io.confluent.connect.s3.format.json.JsonFormat",
    "s3.part.size": "5242880",
    "flush.size": "10",
    "rotate.schedule.interval.ms": "60000",
    "partition.duration.ms": "60000",
    "timezone": "UTC",
    "locale": "de_DE",
    "tasks.max": "3",
    "aws.access.key.id": "replace-with-access-key",
    "aws.secret.access.key": "replace-with-secret-key"
}
EOF



file=`echo ${topic_name}.json`
curl -k -s -X PUT -H "Content-Type: application/json" -d @${file} ${kafka_connect}/connectors/${topic_name}/config | jq .

