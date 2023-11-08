# Client versions from OpenSearch CSV Report 

## Overview
This script processes a CSV report generated from OpenSearch using a specific query to filter Kafka logs. The CSV report is then used to create an SQL view based on a predefined Template Data Extraction (TDE) configuration.

## Input
The input is a CSV report from OpenSearch, obtained with the following query parameters:
- Filter by `clusterId`
- Filter by `logger` with value `kafka.request.logger`
- Search for messages containing `clientInformation`

```json
GET / *.json.kafka* /_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "clusterId": "pkc-xxxxx" } },
        { "match": { "logger": "kafka.request.logger" } },
        { "match_phrase": { "message": "clientInformation" } }
      ]
    }
  }
}
```

## SQL View Configuration
The TDE configuration creates a view named `clientInfoView` in the `clientInformation` schema. The view includes the following columns, which may contain null values:
- Timestamp
- softwareName
- softwareVersion
- clientId
- clientAddress
- requestApiKeyName
- topics
- organizationId
- environmentId
- clusterId
- userResourceIdKey

## Usage
Run the script by providing the path to the OpenSearch CSV report. Optionally, you can specify an SQL query to customize the report generation.

```bash
./start.sh <path_to_csv_report> [<optional_sql_query>]
```
Examples:

```bash
#select All columns
./start.sh On_demand_report_2023-11-08T10_09_39.098Z_ed5567a0-7e1e-11ee-94b9-ff90b7753c4f.csv 
```

```bash
#select specific columns
./start.sh On_demand_report_2023-11-08T10_09_39.098Z_ed5567a0-7e1e-11ee-94b9-ff90b7753c4f.csv "select distinct userResourceIdKey, clientId, softwareName, softwareVersion from clientInformation.clientInfoView;"
```


## Default Behavior
If no SQL query is provided as an argument, the script defaults to using `SELECT * FROM clientInformation.clientInfoView;` to generate the report.

## Report Generation
The script outputs a final report in CSV format. This report is based on the SQL view `clientInfoView` and can include all columns defined in the TDE configuration. To customize the report output, provide an alternative SQL query when running the script.

Replace `start.sh` with the actual filename of your script. Place this `README.md` in the same directory as your script to serve as documentation for users.
