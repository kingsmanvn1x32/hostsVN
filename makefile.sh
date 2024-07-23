#!/bin/sh

echo "Preparing files..."
# convert hosts to filters
cat source/hosts.txt | grep "0.0.0.0" | awk '{print $2}' >source/adserver-all.tmp
if [ "$(uname)" == "Darwin" ]; then
	sed -i "" "s/www\.//g" source/adserver-all.tmp
else
	sed -i "s/www\.//g" source/adserver-all.tmp
fi
sort -u -o source/adserver-all.tmp source/adserver-all.tmp

cat source/hosts-VN.txt | grep "0.0.0.0" | awk '{print $2}' >source/adserver.tmp
if [ "$(uname)" == "Darwin" ]; then
	sed -i "" "s/www\.//g" source/adserver.tmp
else
	sed -i "s/www\.//g" source/adserver.tmp
fi
sort -u -o source/adserver.tmp source/adserver.tmp

echo "Making titles..."
# make time stamp & count blocked
TIME_STAMP=$(date +'%d %b %Y %H:%M')
VERSION=$(date +'%y%m%d%H%M')
LC_NUMERIC="en_US.UTF-8"
DOMAIN=$(printf "%'.3d\n" $(cat source/hosts-group.txt source/hosts-VN-group.txt source/hosts-VN.txt source/hosts.txt source/hosts-extra.txt | grep "0.0.0.0" | wc -l))
DOMAIN_VN=$(printf "%'.3d\n" $(cat source/hosts-VN-group.txt source/hosts-VN.txt | grep "0.0.0.0" | wc -l))
RULE=$(printf "%'.3d\n" $(cat source/adservers.txt source/adservers-all.txt source/adserver.tmp source/adserver-all.tmp source/adservers-extra.txt source/exceptions.txt | grep -v '!' | wc -l))
RULE_VN=$(printf "%'.3d\n" $(cat source/adservers.txt source/adserver.tmp | grep -v '!' | wc -l))
HOSTNAME=$(cat source/config-hostname.txt)

echo "Creating adserver file..."
# create temp adserver files
cat source/adservers.txt source/adserver.tmp | grep -v '!' | awk '{print $1}' >>tmp/adservers.tmp
cat source/adservers-all.txt source/adserver-all.tmp | grep -v '!' | awk '{print $1}' >>tmp/adservers-all.tmp
cat source/adservers-extra.txt | grep -v '!' | awk '{print $1}' >>tmp/adservers-extra.tmp
cat source/exceptions.txt | grep -v '!' | awk '{print $1}' >>tmp/exceptions.tmp

echo 'payload:' >option/hostsVN-clash-rule.yaml
cat tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp | awk '{print "  - \047+."$1"\047"}' >>option/hostsVN-clash-rule.yaml

echo '{
  "version": 2,
  "rules": [
    {
      "domain": [' >option/hostsVN-singbox-rule.json
cat tmp/exceptions.tmp | awk '{print "        \""$1"\","}' | sed -e 's///gm' | sed -e 's/\n//gm' | sed '$ s/,$//' >>option/hostsVN-singbox-rule.json
echo '      ],
      "domain_suffix": [' >>option/hostsVN-singbox-rule.json
cat tmp/adservers.tmp tmp/adservers-all.tmp tmp/adservers-extra.tmp | awk '{print "        \""$1"\","}' | sed -e 's///gm' | sed -e 's/\n//gm' | sed '$ s/,$//' >>option/hostsVN-singbox-rule.json
echo '      ],
      "domain_keyword": [' >>option/hostsVN-singbox-rule.json
cat source/config-rule.txt | awk '{print "        \""$1"\","}' | sed -e 's///gm' | sed -e 's/\n//gm' | sed '$ s/,$//' >>option/hostsVN-singbox-rule.json
echo '      ],
      "domain_regex": [' >>option/hostsVN-singbox-rule.json
cat source/config-rewrite.txt | grep -v '#' | grep -v -e '^[[:space:]]*$' | awk '{print "        \""$1"\","}' | sed -e 's///gm' | sed -e 's/\n//gm' | sed -e '$ s/,$//' | sed -e 's/\//\\\//gm' | sed -e 's/\\/\\\\/gm' >>option/hostsVN-singbox-rule.json
echo '      ]
    }
  ]
}' >>option/hostsVN-singbox-rule.json

# remove tmp file
rm -rf tmp/*.tmp
rm -rf source/*.tmp

# check duplicate
echo "Checking duplicate..."
sort option/domain.txt | uniq -d
sort filters/adservers-all.txt | uniq -d
# read -p "Completed! Press enter to close"
echo "Completed!"
