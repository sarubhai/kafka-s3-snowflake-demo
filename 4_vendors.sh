topic_name='vendors'
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

res=`curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema": "{\"type\": \"int\"}", "value_schema": "{\"type\":\"record\",\"name\":\"'${topic_name}'\",\"fields\":[{\"name\":\"vendor_id\",\"type\":\"int\"},{\"name\":\"vendor_name\",\"type\":\"string\"},{\"name\":\"due_amount\",\"type\":\"double\"}]}", "records": [{"key":1,"value":{"vendor_id":1,"vendor_name":"John Doe","due_amount":5100.50}}]}' | jq`

ksid=`echo $res | jq .key_schema_id`
vsid=`echo $res | jq .value_schema_id`

curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":2,"value":{"vendor_id":2,"vendor_name":"Tom Hanks","due_amount":197700.75}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":3,"value":{"vendor_id":3,"vendor_name":"Jane Doe","due_amount":2100}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":4,"value":{"vendor_id":4,"vendor_name":"John Smith","due_amount":7000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":5,"value":{"vendor_id":5,"vendor_name":"Harry Page","due_amount":6000.80}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":2,"value":{"vendor_id":2,"vendor_name":"Tom Hanks","due_amount":190000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":3,"value":{"vendor_id":3,"vendor_name":"Jane Doe","due_amount":2500}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"vendor_id":6,"vendor_name":"Yo Man","due_amount":5000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":7,"value":{"vendor_id":7,"vendor_name":"Sam","due_amount":1500}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":8,"value":{"vendor_id":8,"vendor_name":"Jam","due_amount":2300}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":9,"value":{"vendor_id":9,"vendor_name":"Ram","due_amount":5400}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":10,"value":{"vendor_id":10,"vendor_name":"Tam","due_amount":6000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"vendor_id":6,"vendor_name":"Yo Man","due_amount":6000}}]}'

curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":11,"value":{"vendor_id":11,"vendor_name":"Suzi","due_amount":3220}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":12,"value":{"vendor_id":12,"vendor_name":"Suji","due_amount":394567}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":13,"value":{"vendor_id":13,"vendor_name":"Sumi","due_amount":21578}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":14,"value":{"vendor_id":14,"vendor_name":"Susu","due_amount":3467}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":15,"value":{"vendor_id":15,"vendor_name":"Sani","due_amount":73927}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":16,"value":{"vendor_id":16,"vendor_name":"Sadi","due_amount":22745}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":17,"value":{"vendor_id":17,"vendor_name":"Sapi","due_amount":12834}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":18,"value":{"vendor_id":18,"vendor_name":"Badu","due_amount":229654}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":19,"value":{"vendor_id":19,"vendor_name":"Badi","due_amount":2223446}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":20,"value":{"vendor_id":20,"vendor_name":"Bagi","due_amount":74336}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"vendor_id":6,"vendor_name":"Yo Man","due_amount":7000}}]}'

curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":21,"value":{"vendor_id":21,"vendor_name":"Hill","due_amount":22266}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":22,"value":{"vendor_id":22,"vendor_name":"Holl","due_amount":3222}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":23,"value":{"vendor_id":23,"vendor_name":"Hall","due_amount":12344}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":24,"value":{"vendor_id":24,"vendor_name":"Hack","due_amount":2566}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":25,"value":{"vendor_id":25,"vendor_name":"Hot","due_amount":2345}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":26,"value":{"vendor_id":26,"vendor_name":"Pot","due_amount":24567}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":27,"value":{"vendor_id":27,"vendor_name":"Poll","due_amount":22455}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"vendor_id":6,"vendor_name":"Yo Man","due_amount":5000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"vendor_id":6,"vendor_name":"Yo Man","due_amount":4000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":28,"value":{"vendor_id":28,"vendor_name":"Dan","due_amount":3467}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":29,"value":{"vendor_id":29,"vendor_name":"Tan","due_amount":8390}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":30,"value":{"vendor_id":30,"vendor_name":"Zan","due_amount":2468}}]}'

curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":31,"value":{"vendor_id":31,"vendor_name":"Mani","due_amount":2267}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":6,"value":{"vendor_id":6,"vendor_name":"Yo Man","due_amount":10000}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":32,"value":{"vendor_id":32,"vendor_name":"Lila","due_amount":3456}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":33,"value":{"vendor_id":33,"vendor_name":"Lali","due_amount":9283}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":34,"value":{"vendor_id":34,"vendor_name":"Loko","due_amount":9173}}]}'
curl -s -k -X POST -H "Content-Type: application/vnd.kafka.avro.v2+json" -H "Accept: application/vnd.kafka.v2+json" "${rest_proxy}/topics/${topic_name}" --data '{ "key_schema_id": '${ksid}', "value_schema_id": '${vsid}', "records": [{"key":35,"value":{"vendor_id":35,"vendor_name":"Poko","due_amount":9258}}]}'

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

