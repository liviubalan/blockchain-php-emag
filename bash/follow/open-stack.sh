#!/bin/bash

BTC_DIR_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Include file
source "${BTC_DIR_ROOT}/../include/functions.sh"

echo 'Welcome to "Blockchain with PHP" by Liviu Balan!'
echo ''
echo 'Relax and let me configure your EOS machine.'
echo 'All you have to to is to focus on the Blockchain technology.'
echo ''

BTC_VIRTUAL_HOST_ECREDIT='/etc/nginx/sites-available/ecredit.emag.ro.conf'
BTC_VIRTUAL_HOST_BLOCKCHAIN='/etc/nginx/sites-available/blockchain.emag.ro.conf'

# Check directory existence
if [ ! -d "${BTC_VIRTUAL_HOST_ECREDIT}" ]; then
    echo "'${BTC_VIRTUAL_HOST_ECREDIT}' is not a valid file."
    exit 1
fi

# Remove file
sudo rm -rf "${BTC_VIRTUAL_HOST_BLOCKCHAIN}"

# Copy file
sudo cp "${BTC_VIRTUAL_HOST_ECREDIT}" "${BTC_VIRTUAL_HOST_BLOCKCHAIN}"

# Replace value
btc_strf_replace_once 'ecredit' 'blockchain' "${BTC_VIRTUAL_HOST_BLOCKCHAIN}"
btc_strf_replace_once '/var/www/blockchain.emag/web' '/var/www/blockchain.emag/www/public' "${BTC_VIRTUAL_HOST_BLOCKCHAIN}"
btc_strf_replace_once 'app.php' 'index.php' "${BTC_VIRTUAL_HOST_BLOCKCHAIN}"

# Restart Nginx to apply the changes
sudo systemctl restart nginx
