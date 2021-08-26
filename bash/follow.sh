#!/bin/bash

if [ "$#" -lt '1' ]; then
    echo 'Illegal number of parameters.'
    exit 1
fi

BTC_STEP="$1"

if ! [[ "${BTC_STEP}" =~ ^[0-9]+$ ]]; then
    echo 'Step should be an integer positive number.'
    exit 1
fi

BTC_TMP_FILE='./bash/config/config.sh'
if [ ! -f "${BTC_TMP_FILE}" ]; then
    echo "File '${BTC_TMP_FILE}' not found!"
    exit 1
fi

BTC_TMP_FILE='./bash/config/commits.sh'
if [ ! -f "${BTC_TMP_FILE}" ]; then
    echo "File '${BTC_TMP_FILE}' not found!"
    exit 1
fi

source './bash/config/config.sh'
source './bash/config/commits.sh'

BTC_COMMIT_LENGTH=${#BTC_COMMIT_HASH[@]}
if [ "${BTC_STEP}" -lt '1' ] || [ "${BTC_STEP}" -gt "${BTC_COMMIT_LENGTH}" ]; then
    echo "Step should be in 1..${BTC_COMMIT_LENGTH} rage."
    exit 1
fi

BTC_TMP_I=0
for BTC_COMMIT in "${BTC_COMMIT_HASH[@]}"
do
    if [ "${BTC_TMP_I}" -eq "${BTC_STEP}" ]; then
        echo "::${BTC_COMMIT_HASH[BTC_TMP_I]}::"
        echo "Step "${BTC_STEP}": ${BTC_COMMIT_DESCRIPTION[BTC_TMP_I-1]}"

        #  Get the list of all files in a commit
        BTC_COMMIT_FILES=$(git ls-tree --name-only -r "${BTC_COMMIT_HASH[BTC_TMP_I-1]}")

        # \n to array
        mapfile -t BTC_COMMIT_FILES <<< "${BTC_COMMIT_FILES}"

        for BTC_COMMIT_FILE in "${BTC_COMMIT_FILES[@]}"
        do
            echo "${BTC_COMMIT_FILE}"
            if [ -n "${BTC_CONFIG_PHPSTORM}" ]; then
                # Open file in PHPStorm
                $BTC_CONFIG_PHPSTORM --line 1 "${BTC_COMMIT_FILE}"
            fi
        done
    fi

    BTC_TMP_I=$((BTC_TMP_I+1))
done
