GRANT ROLE SYSADMIN TO ROLE TERRAFORM_ROLE;


/*
GCP Related Admin setup
*/
CREATE STORAGE INTEGRATION GCS_STORAGE_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'GCS'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('gcs://raghuram-exec-data-extraction');

DESC INTEGRATION GCS_STORAGE_INTEGRATION;
-- yngjpmjfqr@sfc-au-1-nla.iam.gserviceaccount.com


/*
AWS Related Admin setup
*/
SHOW DATABASES;

CREATE STORAGE INTEGRATION AWS_STORAGE_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::886192468297:role/snowflake_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://ap-southeast-2-886192468297-data-extraction/');
-- QB11547_SFCRole=2_qFSLeG1N0kKnn/Wn2KvjGcn+93E=

DESC INTEGRATION AWS_STORAGE_INTEGRATION;

GRANT USAGE ON INTEGRATION AWS_STORAGE_INTEGRATION TO ROLE TERRAFORM_ROLE;

LS @CURRENCY_STAGE;
DESC STAGE CURRENCY_STAGE;