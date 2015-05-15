#!/bin/sh

if [ $# -ne 1 ]
then
        echo "USAGE: $0 ACCESS_TOKEN" 
        echo "Where ACCESS_TOKEN is the access token obtained during authentication"
        exit 1
fi

access_token=${1}

echo "##########"
echo "Here is the curl command you are sending"
cat << EOF 
curl -L --include 
     -H "X-API-Version:1.5" 
     -H "Authorization: Bearer $access_token" 
     -X GET "https://my.rightscale.com/api/deployments.xml"
EOF
echo ""
echo "#########"
echo ""
echo "Hit return to continue ..."
read anykey
echo ""

# The -L causes curl to follow the redirect that my.rightscale.com returns
curl -L --include \
     -H "X-API-Version:1.5" \
     -H "Authorization: Bearer $access_token" \
     -X GET "https://my.rightscale.com/api/deployments.xml"

echo ""
