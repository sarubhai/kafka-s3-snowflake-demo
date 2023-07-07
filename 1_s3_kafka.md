### Create S3 Bucket
- **Name**: replace-with-bucket-name
- **AWS Region**: eu-central-1
- **Access**: Bucket and objects not public


### Create IAM Policy
- **Policy name**: kafka_access_policy
- **Description**: Kafka Access Policy for KafkaConnect S3Sink
- **Permissions**:
```
{
   "Version":"2012-10-17",
   "Statement":[
     {
         "Effect":"Allow",
         "Action":[
           "s3:ListAllMyBuckets"
         ],
         "Resource":"arn:aws:s3:::*"
     },
     {
         "Effect":"Allow",
         "Action":[
           "s3:ListBucket",
           "s3:GetBucketLocation"
         ],
         "Resource":"arn:aws:s3:::replace-with-bucket-name"
     },
     {
         "Effect":"Allow",
         "Action":[
           "s3:PutObject",
           "s3:GetObject",
           "s3:AbortMultipartUpload",
           "s3:PutObjectTagging"
         ],
         "Resource":"arn:aws:s3:::replace-with-bucket-name/*"
     }
   ]
}
```

### Create IAM User
- **User name**: kafka_access_user
- **Console access**: Disabled
- **Permission Options**:
  - **Attach policies directly**
    - **Permissions policies**: kafka_access_policy

### Create Access Key
- Users -> kafka_access_user -> Security credentials -> Access keys
- **Create access key**
- **Use case**: Command Line Interface (CLI)

#### Note down the property values for,
- **Access key**:         ABCDEFGHIJKLMNOPQRST
- **Secret access key**:  ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMN
