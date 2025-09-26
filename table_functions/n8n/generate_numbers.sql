CREATE OR REPLACE TABLE FUNCTION `${BQ_PROJECT}.${BQ_DATASET}.generate_numbers`(
  start_num INT64,
  end_num INT64,
  step INT64
)
RETURNS TABLE<generated_number INT64>
AS (
  SELECT
    n AS generated_number
  FROM
    UNNEST(GENERATE_ARRAY(start_num, end_num, step)) AS n
);
