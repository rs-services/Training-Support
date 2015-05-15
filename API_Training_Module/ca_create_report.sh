#!/bin/sh

if [ $# -ne 3 ]
then
        echo "USAGE: $0 ACCESS_TOKEN REPORT_NAME ACCOUNT_ID " 
        echo "Where ACCESS_TOKEN is the access token obtained from authenticating."
        echo "Where REPORT_NAME is a name you want to give the report you are creating."
        echo "Where ACCOUNT_ID is the account number you want the report to filter on."
        exit 1
fi

# This is the token returned from the previous authentication
access_token=${1}  
report_name=${2}
account_id=${3}

echo "##########"
echo "Here is the curl command you are sending"
cat << EOF 
curl --include 
    -H "X-API-Version:1.0" 
    -H "Authorization: Bearer ${access_token}" 
    -X POST https://analytics.rightscale.com/api/scheduled_reports 
        -d frequency="monthly" 
        -d name="${report_name}" 
        -d attach_csv="true" 
        -d filters="[{"type":"instance:account_id","value":"${account_id}","label":"My Account ${account_id}"}]" 
        
EOF
echo ""
echo "#########"
echo ""
echo "Hit return to continue ..."
read anykey
echo ""

curl --include \
    -H "X-API-Version:1.0" \
    -H "Authorization: Bearer ${access_token}" \
    -X POST https://analytics.rightscale.com/api/scheduled_reports \
        -d frequency="monthly" \
        -d name="${report_name}" \
        -d attach_csv="true" \
        -d filters="[{\"type\":\"instance:account_id\",\"value\":\"${account_id}\",\"label\":\"My Account ${account_id}\"}]" 
            
echo ""
echo ""