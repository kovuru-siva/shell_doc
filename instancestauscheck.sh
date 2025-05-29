

#!/bin/bash
LOG() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}
AMI_ID="ami-06e753fac3cb1f27f"  # Replace with your AMI ID
REGION="ap-south-1"  # Replace with your desired region
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
# Log the start of the script
echo "Script started at $(date)" >> $LOG_FILE
# Launch an EC2 instance
INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t2.micro --region $REGION --query 'Instances[0].InstanceId' --output text)
if [ -z "$INSTANCE_ID" ]; then
  LOG "Failed to launch instance."
  exit 1
fi
LOG "Instance launched with ID: $INSTANCE_ID"
# Wait for the instance to be in running state
while true; do
  STATE=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query 'Reservations[0].Instances[0].State.Name' --output text)

  if [ "$STATE" == "running" ]; then
    LOG "Instance is running."
    break
  elif [ "$STATE" == "pending" ]; then
    LOG "Instance is still pending..."
  else
    LOG "Instance state: $STATE"
    exit 1
  fi

  sleep 5
done
LOG "Instance $INSTANCE_ID is now running."
# Log the instance info in JSON format
LOG "Fetching instance details in JSON format."
# Display the instance info in JSON format


aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --output json
if [ $? -ne 0 ]; then
  LOG "Failed to fetch instance details."
  exit 1
fi
LOG "Instance details fetched successfully."
# Log the termination of the instance
LOG "Terminating instance $INSTANCE_ID."
# Display the instance info in JSON format
aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --output json
if [ $? -ne 0 ]; then
  LOG "Failed to fetch instance details."
  exit 1
fi
LOG "Instance details fetched successfully."
# Terminate the instance
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION
if [ $? -eq 0 ]; then
  LOG "Instance $INSTANCE_ID terminated successfully."
else
  LOG "Failed to terminate instance $INSTANCE_ID."
  exit 1
fi
LOG "Script completed successfully."
LOG "Instance $INSTANCE_ID has been terminated."
LOG "Exiting script."
echo "Script completed successfully. Instance $INSTANCE_ID has been terminated. Exiting script."
# End of script
# Log the end of the script
echo "Script ended at $(date)" >> $LOG_FILE
# Display the log file content
cat $LOG_FILE
##################################


