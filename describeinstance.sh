#!/bin/bash
# This script checks the status of an instance and performs actions based on its state.
LOG() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}  

#describe the instances running in the region
REGION="$1"  # Replace with your desired region
LOG_FILE="instance_status.log"
# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "AWS CLI is not installed. Please install it and try again."
  exit 1
fi
# Create a log file
if [ ! -f $LOG_FILE ]; then
  touch $LOG_FILE
  if [ $? -ne 0 ]; then
    echo "Failed to create log file: $LOG_FILE. Please check permissions."
    exit 1
  fi
fi

#use region as a command line argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <region>"
    echo "Example: $0 us-west-2"
    exit 1
fi

# Log the start of the script
echo "Script started at $(date)" >> $LOG_FILE

# Describe instances in the specified region
aws ec2 describe-instances --region $REGION --output json | jq -r '.Reservations[].Instances[]' >> $LOG_FILE
if [ $? -ne 0 ]; then
  LOG "Failed to fetch instance details."
  exit 1
fi
LOG "Instance details fetched successfully."

# Display the instance info in JSON format
aws ec2 describe-instances --region $REGION --output json | jq -r '.Reservations[].Instances[]'
if [ $? -ne 0 ]; then
  LOG "Failed to fetch instance details."
  exit 1
fi
LOG "Instance details displayed successfully."

# Log the end of the script
echo "Script ended at $(date)" >> $LOG_FILE
LOG "Script completed successfully."
# End of script


