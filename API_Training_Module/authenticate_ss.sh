#!/bin/sh

if [ $# -ne 3 ] 
then
	echo "USAGE: $0 SHARD ACCOUNT_NUM ACCESS_TOKEN" 
	echo "Where SHARD is 3 or 4 representing the SS shard to connect to."
	echo "Where ACCOUNT_NUM is the number for the account in which you are launching the application."
	echo "Where ACCESS_TOKEN is the access token obtained during API 1.5 authentication"
	exit 1
fi

shard=${1}
accountnum=${2}
access_token=${3}

curl -v -i \
-H "Authorization: Bearer ${access_token}" \
-X GET \
"https://selfservice-${shard}.rightscale.com/api/catalog/new_session?account_id=${accountnum}"
