#!/bin/sh

if [ $# -ne 2 ]
then
        echo "USAGE: $0 API_ENDPOINT REFRESH_TOKEN" 
        echo "Where API_ENDPOINT is your API 1.5 endpoint found in the CM portal."
        echo "Where REFRESH_TOKEN is your refresh token found in the CM portal."
        exit 1
fi

my_token_endpoint=${1}
my_refresh_token=${2}

# We tuck away our shard number for later use
echo ${my_token_endpoint} | cut -d"-" -f2 | cut -d"." -f1 > .my_shard

echo "##########"
echo "Here is the curl command you are sending"
cat << EOF 
curl -s --include 
    -H "X-API-Version:1.5" 
    --request POST "$my_token_endpoint" 
    -d "grant_type=refresh_token" 
    -d "refresh_token=$my_refresh_token"
EOF
echo ""
echo "#########"
echo ""
echo "Hit return to continue ..."
read anykey
echo ""

curl -s --include \
        -H "X-API-Version:1.5" \
        --request POST "$my_token_endpoint" \
        -d "grant_type=refresh_token" \
        -d "refresh_token=$my_refresh_token"
        
echo ""
echo ""