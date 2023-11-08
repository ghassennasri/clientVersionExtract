#!/bin/bash

# Function to check if the MarkLogic Docker container is running
check_container() {
  docker inspect --format="{{ .State.Running }}" marklogic-container 2> /dev/null | grep "true" > /dev/null
  if [ $? -eq 0 ]; then
    echo "MarkLogic container is already running."
    container_running=true
  else
    echo "MarkLogic container is not running or does not exist."
    container_running=false
  fi
}

# Check the Docker container status
check_container

# Start Docker container if not running
if [ "$container_running" = false ]; then
  echo "Starting MarkLogic container..."
  ./gradlew dockerRun
  #wait 30sec for MarkLogic to start with countdown
  echo "Waiting for MarkLogic to start..."
  for i in {60..1}; do
   echo -ne "$i\033[0K\r"
   sleep 1
  done
fi



# Deploy the MarkLogic configurations (execute in silent mode)
./gradlew mlDeploy -q

# Check for the correct number of arguments is not less than 1
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <path_to_csv_file> <optional_sql_query>"
    exit 1
fi

# The first argument is the path to the CSV file
CSV_FILE_PATH="$1"

echo "Importing data from $CSV_FILE_PATH..."
# Import data using MLCP with the provided file path
./gradlew importData -PfilePath="$CSV_FILE_PATH"

echo "Import complete!"

#curl --anyauth --user admin:admin -X POST -i \
#    --data-urlencode module=/flatten.sjs \
#    -H "Content-type: application/x-www-form-urlencoded" \
#    -H "Accept: multipart/mixed" \
#    http://localhost:8000/v1/invoke

# Assign the second command line argument to the variable 'sqlQuery', 
# if no argument is given, default to 'SELECT * FROM clientInformation.clientInfoView;'
sqlQuery=${2:-"SELECT * FROM clientInformation.clientInfoView;"}
# Generate the report
echo "Generating report with SQL query: $sqlQuery"

curl --anyauth --user admin:admin -X POST \
    --data-urlencode module=/generate_report.sjs \
    --data-urlencode vars="{"sqlQuery":\" $sqlQuery\"}" \
    -H "Content-type: application/x-www-form-urlencoded" \
    -H "Accept: multipart/mixed" \
    http://localhost:8000/v1/invoke --output report.csv

# Extract the boundary string dynamically (assumes it is the first line)
boundary=$(head -n 1 report.csv)

# Use sed to delete everything before the first occurrence of the boundary
# and after the last occurrence of the boundary, including the boundary lines themselves
sed -n '/'"$boundary"'/,/'"$boundary"'/ {/'"$boundary"'/!p}' report.csv > final_report.csv

#clear Documents database
curl --anyauth --user  admin:admin -i -X DELETE \
    http://localhost:8000/LATEST/search

rm report.csv
# Print completion message
echo "MarkLogic setup, data import, and report generation complete!"

