singbox_url=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases" | grep -o -m 1 '"browser_download_url":\s"http[^"]*-linux-amd64v3\.tar\.gz' | sed -r 's/"browser_download_url":\s"//')
singbox_url=$(echo -e "${singbox_url}" | tr -d '[:space:]')
echo "singbox_url: $singbox_url"
singbox_namezip=$(echo "$singbox_url" | cut -d/ -f9)
singbox_name=$(echo "$singbox_namezip" | cut -c 1-$((${#singbox_namezip}-7)))
singbox_path="./$singbox_name/sing-box"
curl -sSLO $singbox_url
chmod +x $singbox_namezip
tar -xzvf $singbox_namezip
chmod +x $singbox_path
$singbox_path rule-set compile --output option/hostsVN-singbox-rule.srs option/hostsVN-singbox-rule.json
