#!/bin/sh

if [ $# -ne 2 ]
then
        echo "USAGE: $0 ACCOUNT_ID ACCESS_TOKEN" 
        echo "Where ACCOUNT_ID is the account number you are authenticating to."
        echo "Where ACCESS_TOKEN is the access token obtained during authentication"
        exit 1
fi

account_id=${1}
access_token=${2}

# Get the shard stored earlier during API 1.5 authentication
my_shard=`cat ./.my_shard`

echo "##########"
echo "Here is the curl command you are sending"
cat << EOF 
curl -v -i 
        -H "Authorization: Bearer ${access_token}" 
        -X GET 
        https://selfservice-${my_shard}.rightscale.com/api/catalog/new_session?account_id=${account_id}"
EOF
echo ""
echo "#########"
echo ""
echo "Hit return to continue ..."
read anykey
echo ""

curl -i \
        -H "Authorization: Bearer ${access_token}" \
        -X GET \
        "https://selfservice-${my_shard}.rightscale.com/api/catalog/new_session?account_id=${account_id}"

echo ""
