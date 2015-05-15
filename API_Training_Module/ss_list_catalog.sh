#!/bin/sh

if [ $# -ne 2 ] 
then
	echo "USAGE: $0 ACCOUNT_NUM ACCESS_TOKEN" 
	echo "Where ACCOUNT_NUM is the number for the account in which you are launching the application."
	echo "Where ACCESS_TOKEN is the access token obtained during API 1.5 authentication"
	exit 1
fi

accountnum=${1}
access_token=${2}

# Get the shard stored earlier during API 1.5 authentication
my_shard=`cat ./.my_shard`

echo "##########"
echo "Here is the curl command you are sending"
cat << EOF 
curl -v -i 
     -H "Authorization: Bearer ${access_token}" 
     -H 'X-API-VERSION:1.0' 
     -X GET 
    "https://selfservice-${my_shard}.rightscale.com/api/catalog/catalogs/${accountnum}/applications"
EOF
echo ""
echo "#########"
echo ""
echo "Hit return to continue ..."
read anykey
echo ""

curl -v -i \
     -H "Authorization: Bearer ${access_token}" \
     -H 'X-API-VERSION:1.0' \
     -X GET \
    "https://selfservice-${my_shard}.rightscale.com/api/catalog/catalogs/${accountnum}/applications"

echo ""
