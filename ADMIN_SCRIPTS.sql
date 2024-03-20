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


/*
Admin scripts for external functions
*/

CREATE OR REPLACE API INTEGRATION EXTERNAL_FUNCTION_API_INTEGRATION
API_PROVIDER=AWS_API_GATEWAY
API_AWS_ROLE_ARN='arn:aws:iam::XXXXXXXXX:role/ap-southeast-2-XXXXXXXX-external-function-proxy-role'
API_ALLOWED_PREFIXES=('https://dv1ogox5oi.execute-api.ap-southeast-2.amazonaws.com/test/')
ENABLED=true;

DESCRIBE INTEGRATION EXTERNAL_FUNCTION_API_INTEGRATION;

GRANT USAGE ON INTEGRATION EXTERNAL_FUNCTION_API_INTEGRATION TO ROLE TERRAFORM_ROLE;

SHOW EXTERNAL FUNCTIONS;

CREATE OR REPLACE EXTERNAL FUNCTION CURRENCY_EXCHANGE_FUNCTION(exchange_date VARCHAR, exchange_currency VARCHAR)
    RETURNS NUMBER(38,2)
    API_INTEGRATION = EXTERNAL_FUNCTION_API_INTEGRATION
    AS 'https://xxxxxxxxx.execute-api.ap-southeast-2.amazonaws.com/test/action';

SELECT CURRENCY_EXCHANGE_FUNCTION(TO_VARCHAR(current_date()-1), 'usd') as exchange_rate;


-- Integrations for COVID Data
CREATE STORAGE INTEGRATION AWS_COVID_STORAGE_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::886192468297:role/snowflake_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://ap-southeast-2-886192468297-covid/');
-- QB11547_SFCRole=2_qFSLeG1N0kKnn/Wn2KvjGcn+93E=

DESC INTEGRATION AWS_COVID_STORAGE_INTEGRATION;

GRANT USAGE ON INTEGRATION AWS_COVID_STORAGE_INTEGRATION TO ROLE TERRAFORM_ROLE;

CREATE STAGE AWS_COVID_STAGE
  URL='s3://ap-southeast-2-886192468297-covid/'
  STORAGE_INTEGRATION = AWS_COVID_STORAGE_INTEGRATION;

CREATE FILE FORMAT CSV_FORMAT
  TYPE = csv
  PARSE_HEADER = true;