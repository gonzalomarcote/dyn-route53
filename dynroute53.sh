#!/bin/bash
#
# Route53 Dynamic DNS script
#
# Version, Author (1.0, Gonzalo Marcote <gonzalomarcote@gmail.com>)
#
# Script to check the current external IP and change it in Route53 if it have changed
# Required packages: awscli, jq, moreutils
#
# Configure awscli with your aws account with 'aws configure' 
# Create one route53-dyndns.json with the following strcucture:
#{
#  "Comment": "Update record to reflect new IP address of home router",
#  "Changes": [
#    {
#      "Action": "UPSERT",
#      "ResourceRecordSet": {
#        "Name": "yourdomain.com.",
#        "Type": "A",
#        "TTL": 300,
#        "ResourceRecords": [
#          {
#            "Value": "8.8.8.8"
#          }
#        ]
#      }
#    }
#  ]
#}
#
# Set some global vars
extIp=$(/usr/bin/curl -s ipinfo.io/ip)
record=yourdomain.com.
zoneId=your-route53-zoneId
awsIp=$(/usr/local/bin/aws route53 test-dns-answer --hosted-zone-id $zoneId --record-name $record --record-type A --query 'RecordData[]' --output text)
mail=your-email
json=/your/path/route53-dyndns.json

# Check current IP and compare with AWS route53 configured one
#---------------------------------------------------------------
/bin/echo "Your current external IP is: $extIp"
/bin/echo "Your current configured IP for the $record record is $awsIp"

# If they are different update AWS IP with the current one
#----------------------------------------------------------
if [ $extIp != $awsIp ]
then
  	echo "Your $record AWS rcord is: $awsIp and has changed to: $extIp Updating it..."
	# We update json file with new IP and change it with aws
	/usr/bin/jq --arg extIp "$extIp" '.Changes[].ResourceRecordSet.ResourceRecords[].Value = $extIp' $json|sponge $json
  	/usr/local/bin/aws route53 change-resource-record-sets --hosted-zone-id $zoneId --change-batch file://$json
  	/bin/echo "Ip changed"
	# We send email warning. Comment the following line if not mail server configured
	/bin/echo "External IP has changed to $extIp and configured in route53" | /usr/bin/mail -s "Warning - External IP has changed" $mail
else
	/bin/echo "IP has not changed"
fi
