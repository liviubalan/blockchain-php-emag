#!/bin/bash

BTC_DIR_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo 'Follow the wizard.' && exit 1

# Check parameter count
if [ "$#" -lt '1' ]; then
    echo 'Illegal number of parameters.'
    exit 1
fi

BTC_STEP="$1"

# Check step to be positive integer
if ! [[ "${BTC_STEP}" =~ ^[0-9]+$ ]]; then
    echo 'Step should be an integer positive number.'
    exit 1
fi

# Check file existence
BTC_TMP_FILE="${BTC_DIR_ROOT}/bash/follow/config/config.sh"
if [ ! -f "${BTC_TMP_FILE}" ]; then
    echo "File '${BTC_TMP_FILE}' not found."
    exit 1
fi

# Check file existence
BTC_TMP_FILE="${BTC_DIR_ROOT}/bash/follow/config/commits.sh"
if [ ! -f "${BTC_TMP_FILE}" ]; then
    echo "File '${BTC_TMP_FILE}' not found."
    exit 1
fi

# Include files
source "${BTC_DIR_ROOT}/bash/follow/config/config.sh"
source "${BTC_DIR_ROOT}/bash/follow/config/commits.sh"

# Check empty data
if [ -z "${BTC_CONFIG_GIT_2}" ]; then
    echo "Value for 'BTC_CONFIG_GIT_2' not set."
    exit 1
fi

# Check directory existence
if [ ! -d "${BTC_CONFIG_GIT_2}" ]; then
    echo "'${BTC_CONFIG_GIT_2}' is not a valid directory."
    exit 1
fi

# Check step to be in 1..length interval
BTC_COMMIT_LENGTH=${#BTC_COMMIT_HASH[@]}
if [ "${BTC_STEP}" -lt '1' ] || [ "${BTC_STEP}" -gt "${BTC_COMMIT_LENGTH}" ]; then
    echo "Step should be in 1..${BTC_COMMIT_LENGTH} rage."
    exit 1
fi

# Get current working directory
BTC_CONFIG_GIT=$(pwd)
BTC_TMP_I=0
for BTC_COMMIT in "${BTC_COMMIT_HASH[@]}"
do
    # Identify step
    if [ "${BTC_TMP_I}" -eq "${BTC_STEP}" ]; then
        # Git2 project
        cd "${BTC_CONFIG_GIT_2}"
        git fetch
        # Reset Git to current commit
        git reset --hard "${BTC_COMMIT_HASH[BTC_TMP_I]}" >/dev/null 2>&1

        #  Get the list of all files in the commit
        BTC_COMMIT_FILES=$(git diff-tree --no-commit-id --name-only -r "${BTC_COMMIT_HASH[BTC_TMP_I]}")

        # Current project
        cd "${BTC_CONFIG_GIT}"

        # Reset Git to previous commit
        git reset --hard "${BTC_COMMIT_HASH[BTC_TMP_I-1]}" >/dev/null 2>&1

        echo "Step "${BTC_STEP}": ${BTC_COMMIT_DESCRIPTION[BTC_TMP_I]}"
        echo "Previous commit: ${BTC_COMMIT_HASH[BTC_TMP_I-1]}"
        echo "Current commit: ${BTC_COMMIT_HASH[BTC_TMP_I]}"
        echo 'Changed files:'

         # \n to array
         mapfile -t BTC_COMMIT_FILES <<< "${BTC_COMMIT_FILES}"

        for BTC_COMMIT_FILE in "${BTC_COMMIT_FILES[@]}"
        do
            echo "${BTC_COMMIT_FILE}"

            # Copy file
            cp "${BTC_CONFIG_GIT_2}/${BTC_COMMIT_FILE}" "${BTC_CONFIG_GIT}/${BTC_COMMIT_FILE}"

            # Check empty data
            if [ -n "${BTC_CONFIG_PHPSTORM}" ]; then
                # Open file in PhpStorm
                $BTC_CONFIG_PHPSTORM --line 1 "${BTC_COMMIT_FILE}" >/dev/null 2>&1
            fi
        done

        # Commit changes where shown so do not continue to next commit
        break
    fi

    # Increment counter
    BTC_TMP_I=$((BTC_TMP_I+1))
done
