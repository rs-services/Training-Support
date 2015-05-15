#!/bin/sh

if [ $# -ne 2 ] 
then
	echo "USAGE: $0 SHARD ACCESS_TOKEN" 
	echo "Where SHARD is 3 or 4 representing the SS shard to connect to."
	echo "Where ACCESS_TOKEN is the access token obtained during authentication"
	exit 1
fi

shard=${1}
base_uri="us-${shard}.rightscale.com"
access_token=${2}

curl --include \
     -H "X-API-Version:1.5" \
     -H "Authorization: Bearer $access_token" \
     -X GET "https://${base_uri}/api/deployments.xml"
