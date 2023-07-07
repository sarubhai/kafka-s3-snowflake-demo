## AWS
### Create IAM Policy
- **Policy Name**: snowflake_access_policy
- **Description**: Snowflake Access Policy for Snowpipe
- **Permissions**:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "arn:aws:s3:::replace-with-bucket-name/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::replace-with-bucket-name"
        }
    ]
}
```

### Create IAM Role
- **Trusted entity type**: AWS account
- **An AWS account**: This account (replace-with-aws-account-id)
- **Permissions policies**: snowflake_access_policy
- **Role name**: snowflake_access_role
- **Description**: Snowflake Access Role


## Snowflake
### STORAGE INTEGRATION
```
CREATE STORAGE INTEGRATION s3_datalake_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::replace-with-aws-account-id:role/snowflake_access_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://replace-with-bucket-name');


DESC INTEGRATION s3_datalake_integration;
```
#### Note down the property values for,
- **STORAGE_AWS_IAM_USER_ARN**: arn:aws:iam::replace-with-sfaws-account-id:user/abc90000-d
- **STORAGE_AWS_EXTERNAL_ID**: XXXXXXX_SFCRole=2_ABCDEFGHIJKLMNOPQRSTUVWXYZA=


## AWS
### Modify IAM Role
IAM Role Name: snowflake_access_role
- Roles -> snowflake_access_role -> Trust Relationships -> Trusted entities
- Edit trust policy
```
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::replace-with-sfaws-account-id:user/abc90000-d"
			},
			"Action": "sts:AssumeRole",
			"Condition": {
				"StringEquals": {
					"sts:ExternalId": "XXXXXXX_SFCRole=2_ABCDEFGHIJKLMNOPQRSTUVWXYZA="
				}
			}
		}
	]
}
```


## Snowflake
### EXTERNAL STAGE
```
CREATE STAGE s3_dl_ext_stage
  URL = 's3://replace-with-bucket-name'
  STORAGE_INTEGRATION = s3_datalake_integration;


DESC STAGE s3_dl_ext_stage;

LIST @s3_dl_ext_stage/cdl/customers;

LIST @s3_dl_ext_stage/cdl/vendors;
```

### FILE FORMAT
```
CREATE OR REPLACE FILE FORMAT s3_datalake_parquet_format
  TYPE = parquet;

CREATE OR REPLACE FILE FORMAT s3_datalake_json_format
  TYPE = json;
```

#### QUERY DATA IN EXTERNAL STAGED FILE
```
SELECT
    $1:customer_id::integer as customer_id, $1:customer_name::text as customer_name, $1:balance::double as balance, 
    $1:kafka_partition::integer, $1:kafka_offset::integer, TO_TIMESTAMP_NTZ($1:kafka_timestamp),
    METADATA$FILENAME as s3_filename, METADATA$FILE_ROW_NUMBER as rownumber_in_file,
    CURRENT_TIMESTAMP as sf_inserted_at, CURRENT_TIMESTAMP as sf_updated_at
FROM @s3_dl_ext_stage
(
    FILE_FORMAT => s3_datalake_parquet_format,
    PATTERN => 'cdl/customers/.*snappy.parquet'
);


SELECT
    $1::integer as customer_id,
    METADATA$FILENAME as s3_filename, METADATA$FILE_ROW_NUMBER as rownumber_in_file,
    CURRENT_TIMESTAMP as sf_inserted_at, CURRENT_TIMESTAMP as sf_updated_at
FROM @s3_dl_ext_stage
(
    FILE_FORMAT => s3_datalake_json_format,
    PATTERN => 'cdl/customers/tombstone/.*keys.json'
);



SELECT
    $1:vendor_id::integer as vendor_id, $1:vendor_name::text as vendor_name, $1:due_amount::double as due_amount, 
    $1:kafka_partition::integer, $1:kafka_offset::integer, TO_TIMESTAMP_NTZ($1:kafka_timestamp),
    METADATA$FILENAME as s3_filename, METADATA$FILE_ROW_NUMBER as rownumber_in_file,
    CURRENT_TIMESTAMP as sf_inserted_at, CURRENT_TIMESTAMP as sf_updated_at
FROM @s3_dl_ext_stage
(
    FILE_FORMAT => s3_datalake_parquet_format,
    PATTERN => 'cdl/vendors/.*snappy.parquet'
);


SELECT
    $1::integer as vendor_id,
    METADATA$FILENAME as s3_filename, METADATA$FILE_ROW_NUMBER as rownumber_in_file,
    CURRENT_TIMESTAMP as sf_inserted_at, CURRENT_TIMESTAMP as sf_updated_at
FROM @s3_dl_ext_stage
(
    FILE_FORMAT => s3_datalake_json_format,
    PATTERN => 'cdl/vendors/tombstone/.*keys.json'
);
```


### CREATE STAGING TABLES
```
CREATE TABLE customers_stg (
    customer_id NUMBER(38, 0), customer_name TEXT, balance REAL, 
    kafka_partition NUMBER(38, 0), kafka_offset NUMBER(38, 0), kafka_timestamp TIMESTAMP_NTZ,
    s3_filename TEXT, rownumber_in_file INTEGER,
    sf_inserted_at TIMESTAMP_NTZ, sf_updated_at TIMESTAMP_NTZ 
);

CREATE TABLE customers_delete_stg (
    customer_id NUMBER(38, 0),
    s3_filename TEXT, rownumber_in_file INTEGER,
    sf_inserted_at TIMESTAMP_NTZ, sf_updated_at TIMESTAMP_NTZ 
);


CREATE TABLE vendors_stg (
    vendor_id NUMBER(38, 0), vendor_name TEXT, due_amount REAL, 
    kafka_partition NUMBER(38, 0), kafka_offset NUMBER(38, 0), kafka_timestamp TIMESTAMP_NTZ,
    s3_filename TEXT, rownumber_in_file INTEGER,
    sf_inserted_at TIMESTAMP_NTZ, sf_updated_at TIMESTAMP_NTZ 
);

CREATE TABLE vendors_delete_stg (
    vendor_id NUMBER(38, 0),
    s3_filename TEXT, rownumber_in_file INTEGER,
    sf_inserted_at TIMESTAMP_NTZ, sf_updated_at TIMESTAMP_NTZ 
);
```

### PIPE
```
CREATE PIPE customers_pipe auto_ingest=true as
COPY INTO customers_stg
FROM (
    SELECT
        $1:customer_id::integer as customer_id, $1:customer_name::text as customer_name, $1:balance::double as balance, 
        $1:kafka_partition::integer, $1:kafka_offset::integer, TO_TIMESTAMP_NTZ($1:kafka_timestamp),
        METADATA$FILENAME as s3_filename, METADATA$FILE_ROW_NUMBER as rownumber_in_file,
        CURRENT_TIMESTAMP as sf_inserted_at, CURRENT_TIMESTAMP as sf_updated_at
    FROM @s3_dl_ext_stage
    (
        FILE_FORMAT => s3_datalake_parquet_format,
        PATTERN => 'cdl/customers/.*snappy.parquet'
    )
);


CREATE PIPE customers_delete_pipe auto_ingest=true as
COPY INTO customers_delete_stg
FROM (
    SELECT
        $1::integer as customer_id,
        METADATA$FILENAME as s3_filename, METADATA$FILE_ROW_NUMBER as rownumber_in_file,
        CURRENT_TIMESTAMP as sf_inserted_at, CURRENT_TIMESTAMP as sf_updated_at
    FROM @s3_dl_ext_stage
    (
        FILE_FORMAT => s3_datalake_json_format,
        PATTERN => 'cdl/customers/tombstone/.*keys.json'
    )
);



CREATE PIPE vendors_pipe auto_ingest=true as
COPY INTO vendors_stg
FROM (
    SELECT
        $1:vendor_id::integer as vendor_id, $1:vendor_name::text as vendor_name, $1:due_amount::double as due_amount, 
        $1:kafka_partition::integer, $1:kafka_offset::integer, TO_TIMESTAMP_NTZ($1:kafka_timestamp),
        METADATA$FILENAME as s3_filename, METADATA$FILE_ROW_NUMBER as rownumber_in_file,
        CURRENT_TIMESTAMP as sf_inserted_at, CURRENT_TIMESTAMP as sf_updated_at
    FROM @s3_dl_ext_stage
    (
        FILE_FORMAT => s3_datalake_parquet_format,
        PATTERN => 'cdl/vendors/.*snappy.parquet'
    )
);

CREATE PIPE vendors_delete_pipe auto_ingest=true as
COPY INTO vendors_delete_stg
FROM (
    SELECT
        $1::integer as vendor_id,
        METADATA$FILENAME as s3_filename, METADATA$FILE_ROW_NUMBER as rownumber_in_file,
        CURRENT_TIMESTAMP as sf_inserted_at, CURRENT_TIMESTAMP as sf_updated_at
    FROM @s3_dl_ext_stage
    (
        FILE_FORMAT => s3_datalake_json_format,
        PATTERN => 'cdl/vendors/tombstone/.*keys.json'
    )
);



SHOW PIPES;
```
#### Note down the property values for,
- **notification_channel** : arn:aws:sqs:eu-central-1:replace-with-sfaws-account-id:sf-snowpipe-ABCDEFGHIJKLMNOPQRSTU-ABCDEFGHIJKLMNOPQRSTUV


## AWS
## Create S3 Bucket Event Notification
S3 Bucket Name: replace-with-bucket-name
- Bucket -> Properties -> Event notifications
- Create event notification
- **Event Name**: auto-ingest-snowflake-snowpipe
- **Event Types**: 
    - **Object creation**: All object create events (s3:ObjectCreated:*)
- **Destination**: SQS Queue
- **Specify SQL Queue**: Enter SQS queue ARN
- **SQS queue**: arn:aws:sqs:eu-central-1:replace-with-sfaws-account-id:sf-snowpipe-ABCDEFGHIJKLMNOPQRSTU-ABCDEFGHIJKLMNOPQRSTUV


## Snowflake
### Load Historical Files
```
ALTER PIPE customers_pipe REFRESH;
ALTER PIPE customers_delete_pipe REFRESH;
ALTER PIPE vendors_pipe REFRESH;
ALTER PIPE vendors_delete_pipe REFRESH;

SELECT SYSTEM$PIPE_STATUS( 'customers_pipe' );
SELECT SYSTEM$PIPE_STATUS( 'customers_delete_pipe' );
SELECT SYSTEM$PIPE_STATUS( 'vendors_pipe' );
SELECT SYSTEM$PIPE_STATUS( 'vendors_delete_pipe' );
```


### Test Data Loaded in Staging Tables
```
SELECT * FROM customers_stg ORDER BY customer_id, kafka_timestamp DESC;
SELECT * FROM customers_delete_stg ORDER BY sf_inserted_at, rownumber_in_file;
SELECT * FROM vendors_stg ORDER BY vendor_id, kafka_timestamp DESC;
SELECT * FROM vendors_delete_stg ORDER BY sf_inserted_at, rownumber_in_file;
```

### CREATE TARGET TABLES
```
CREATE TABLE customers (
    customer_id NUMBER(38, 0), customer_name TEXT, balance REAL, 
    kafka_partition NUMBER(38, 0), kafka_offset NUMBER(38, 0), kafka_timestamp TIMESTAMP_NTZ,
    s3_filename TEXT, rownumber_in_file INTEGER,
    sf_inserted_at TIMESTAMP_NTZ, sf_updated_at TIMESTAMP_NTZ,
    etl_created_at TIMESTAMP_NTZ, etl_updated_at TIMESTAMP_NTZ, etl_deleted_at TIMESTAMP_NTZ
);


CREATE TABLE vendors (
    vendor_id NUMBER(38, 0), vendor_name TEXT, due_amount REAL, 
    kafka_partition NUMBER(38, 0), kafka_offset NUMBER(38, 0), kafka_timestamp TIMESTAMP_NTZ,
    s3_filename TEXT, rownumber_in_file INTEGER,
    sf_inserted_at TIMESTAMP_NTZ, sf_updated_at TIMESTAMP_NTZ,
    etl_created_at TIMESTAMP_NTZ, etl_updated_at TIMESTAMP_NTZ
);
```


### Merge Data + Soft Delete
```
MERGE INTO customers tgt USING 
(
    WITH ordered_records AS (
        SELECT 
            *, RANK() OVER(PARTITION BY customer_id ORDER BY kafka_timestamp DESC) AS rnk
        FROM customers_stg
    ),
    latest_records AS (
        SELECT
            *
        FROM ordered_records
        WHERE rnk = 1
    ),
    last_read AS (
        SELECT
            IFNULL(MAX(kafka_timestamp), '1900-01-01 00:00:00.000'::TIMESTAMP_NTZ) AS last_time
        FROM customers
    ),
    new_records AS (
        SELECT
            *
        FROM latest_records, last_read
        WHERE kafka_timestamp > last_read.last_time
    )
    SELECT
        *
    FROM new_records
) AS src
ON tgt.customer_id = src.customer_id
WHEN MATCHED THEN
    UPDATE SET 
        tgt.customer_name = src.customer_name, tgt.balance = src.balance, 
        tgt.kafka_partition = src.kafka_partition, tgt.kafka_offset  = src.kafka_offset, tgt.kafka_timestamp  = src.kafka_timestamp, 
        tgt.s3_filename = src.s3_filename, tgt.rownumber_in_file = src.rownumber_in_file, 
        tgt.sf_inserted_at = src.sf_inserted_at, tgt.sf_updated_at = src.sf_updated_at,
        etl_updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
    INSERT 
    (
        customer_id, customer_name, balance, kafka_partition, kafka_offset, kafka_timestamp, s3_filename, rownumber_in_file, 
        sf_inserted_at, sf_updated_at, etl_created_at, etl_updated_at, etl_deleted_at
    )
    VALUES 
    (
        src.customer_id, src.customer_name, src.balance, src.kafka_partition, src.kafka_offset, src.kafka_timestamp, src.s3_filename, src.rownumber_in_file,
        src.sf_inserted_at, src.sf_updated_at, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL
    )
;


UPDATE customers
    SET etl_deleted_at = CURRENT_TIMESTAMP
WHERE EXISTS (
    SELECT
        1
    FROM customers_delete_stg
    WHERE customers.customer_id = customers_delete_stg.customer_id
) 
AND etl_deleted_at IS NULL;



SELECT * FROM customers ORDER BY customer_id, kafka_timestamp DESC;
```

### Merge Data + Hard Delete
```
MERGE INTO vendors tgt USING 
(
    WITH ordered_records AS (
        SELECT 
            *, RANK() OVER(PARTITION BY vendor_id ORDER BY kafka_timestamp DESC) AS rnk
        FROM vendors_stg
    ),
    latest_records AS (
        SELECT
            *
        FROM ordered_records
        WHERE rnk = 1
    ),
    last_read AS (
        SELECT
            IFNULL(MAX(kafka_timestamp), '1900-01-01 00:00:00.000'::TIMESTAMP_NTZ) AS last_time
        FROM vendors
    ),
    new_records AS (
        SELECT
            *
        FROM latest_records, last_read
        WHERE kafka_timestamp > last_read.last_time
    )
    SELECT
        *
    FROM new_records
) AS src
ON tgt.vendor_id = src.vendor_id
WHEN MATCHED THEN
    UPDATE SET 
        tgt.vendor_name = src.vendor_name, tgt.due_amount = src.due_amount, 
        tgt.kafka_partition = src.kafka_partition, tgt.kafka_offset  = src.kafka_offset, tgt.kafka_timestamp  = src.kafka_timestamp, 
        tgt.s3_filename = src.s3_filename, tgt.rownumber_in_file = src.rownumber_in_file, 
        tgt.sf_inserted_at = src.sf_inserted_at, tgt.sf_updated_at = src.sf_updated_at,
        etl_updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED THEN
    INSERT 
    (
        vendor_id, vendor_name, due_amount, kafka_partition, kafka_offset, kafka_timestamp, s3_filename, rownumber_in_file, 
        sf_inserted_at, sf_updated_at, etl_created_at, etl_updated_at
    )
    VALUES 
    (
        src.vendor_id, src.vendor_name, src.due_amount, src.kafka_partition, src.kafka_offset, src.kafka_timestamp, src.s3_filename, src.rownumber_in_file,
        src.sf_inserted_at, src.sf_updated_at, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    )
;


DELETE FROM vendors
WHERE EXISTS (
    SELECT
        1
    FROM vendors_delete_stg
    WHERE vendors.vendor_id = vendors_delete_stg.vendor_id
);



SELECT * FROM vendors ORDER BY vendor_id, kafka_timestamp DESC;
```

