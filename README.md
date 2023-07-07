

### Docker Desktop
Below are the resource specification of Docker Desktop to deploy the containers properly.
![Alt text](docker-desktop.png?raw=true "Docker Desktop Settings")

### .env
Create a .env file with the ID for the Kafka Cluster

### 1_s3_kafka
- Create a S3 Bucket
- Create IAM Policy for Read/Write Access to S3 Bucket
- Create IAM User and Access Tokens for Kafka Connect

### 2_kafka-docker-compose.yml
The docker compose will deploy the following containers-

- Single Broker Kafka Cluster with KRaft
- Schema Registry
- Kafka Rest Proxy
- Single node Kafka Connect Cluster
  - S3 Sink Connector
  - Connect Transforms
- Single node ksqlDB Cluster
- Kafka UI

To deploy the containers-
```
docker-compose -f 2_kafka-docker-compose.yml up -d
```

Check the Kafka User Interface at [Kafka UI](http://0.0.0.0:8888)

### 3_customers.sh
This script will create 
- Kafka Topic (customers) topic with 
- Register Avro Schema for Topic (customers)
- Generate Messages in customers topic, along with tombstone records
- Generate & Register Kafka Connect Configuration for S3Sink

### 4_vendors.sh
This script will create 
- Kafka Topic (vendors) topic with 
- Register Avro Schema for Topic (vendors)
- Generate Messages in vendors topic, along with tombstone records
- Generate & Register Kafka Connect Configuration for S3Sink

### 5_s3_snowflake
- Create IAM Policy for Read Access to S3 Bucket
- Create IAM Role for Snowflake Integration
- Create Snowflake Storage Integration
- Create Snowflake External Stage
- Create Snowflake File Formats
- Create Snowflake Staging Tables
- Create Snowflake Pipes
- Create S3 Bucket Event Notification
- Create Snowflake Target Tables
 
