#!/bin/sh

if [ $# -ne 4 ] 
then
	echo "USAGE: $0 ACCOUNT_NUM ACCESS_TOKEN DEPLOYED_APP_NAME APPLICATION_HREF"
	echo "Where ACCOUNT_NUM is the number for the account in which you are launching the application."
	echo "Where ACCESS_TOKEN is the access token obtained during API 1.5 authentication"
	echo "Where DEPLOYED_APP_NAME is the name you want to give the cloud application once it launches."
	echo "Where APPLICATION_HREF is the href for the application in the catalog."
	exit 1
fi

accountnum=${1}
access_token=${2}
cloudapp_name=${3}
application_href=${4}

# Get the shard stored earlier during API 1.5 authentication
my_shard=`cat ./.my_shard`

echo "##########"
echo "Here is the curl command you are sending"
cat << EOF 
curl -i 
     -H "Authorization: Bearer ${access_token}" 
     -H 'X-API-VERSION:1.0' 
     -X POST 
     https://selfservice-${my_shard}.rightscale.com/api/manager/projects/${accountnum}/executions  
        -d name="${cloudapp_name}" 
        -d description="Cloud App deployed via API" 
        -d application_href="${application_href}" 
EOF
echo ""
echo "#########"
echo ""
echo "Hit return to continue ..."
read anykey
echo ""

curl -i \
     -H "Authorization: Bearer ${access_token}" \
     -H 'X-API-VERSION:1.0' \
     -X POST \
     https://selfservice-${my_shard}.rightscale.com/api/manager/projects/${accountnum}/executions  \
	-d name="${cloudapp_name}" \
	-d description="Cloud App deployed via API" \
	-d application_href="${application_href}" 


