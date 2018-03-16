#!/bin/bash
set +x

# #####################################################################
# Registers gitlab runner for use of docker in GitLab CI
# Specific to project: https://gitlab.disney.com/segmentation/pbridge/
#
# Usage: ./create-lists.sh
#
# No arguments required or optional. Will download files automatically
#
# Outputs to STDOUT or STDERR.
# Exit code of 0 denotes success.  None zero exit code failed.
# #####################################################################


# =====================================================================
# F  U  N  C  T  I  O  N  S
# =====================================================================

function usage {
    echo "Usage: ./create-lists.sh"
    echo
    echo "No arguments required or optional. Will download files automatically"
    echo
    echo "Outputs to STDOUT or STDERR."
    echo "Exit code of 0 denotes success.  None zero exit code failed."
}

function echoerr {
    echo "$@" 1>&2;
}

function cmd_exist() {
    which $1 > /dev/null
    if [ $? -ne 0 ]; then
        echoerr "${1} not installed - required for script"
        exit 1
    fi
}

function download() {
    local src_url=$1
    local dest_file=$2

    curl -o ${dest_file} ${src_url}

    if [ $? -eq 0 ] && [ -f ${dest_file} ]; then
        echo "Successfully downloaded ${src_url} to destination ${dest_file}"
    else
        echoerr "Failed to download ${src_url}"
        exit 2
    fi
}

function split_file() {
    local input_file="$1"
    local output_file_prefix="$2"
    # remove leading white space
    local line_count=`wc -l ${input_file} |  sed -e 's/^[[:space:]]*//' | cut -d' ' -f1`
    local count=100

    # split file into top 100, 1000, 10000...
    while [ ${count} -le 1000000 ];
    do
        #echo ${count}
        head -n ${count} ${input_file} > "${output_file_prefix}-${count}.csv"

        if [ $? -ne 0 ]; then
            echoerr "Failed: head -n ${count} ${input_file}"
            exit 3
        fi

        if [ ${line_count} -le ${count} ]; then
            mv "${output_file_prefix}-${count}.csv" "${output_file_prefix}-${line_count}.csv"
            #echo "***** Exiting ${count} with line count ${line_count}"
            break
        fi

        count=$(( $count * 10 ))
    done
}

function push_to_git() {
    local files=$1
}

# =====================================================================
# M  A  I  N     L  O  G  I  C
# =====================================================================

if [ $# -ge 1 ]; then
    usage
    exit 100
fi

# ensure commands available - handles exit
cmd_exist curl
cmd_exist unzip
cmd_exist split

# GLOBALS
TMP=top-recs
TOP_1M='top-1m'
TOP_TLD='top-1m-TLD'
TOP_1M_ZIP="${TOP_1M}.zip"
TOP_TLD_ZIP="${TOP_TLD}.zip"
TOP_1M_CSV="${TOP_1M}.csv"
TOP_TLD_CSV="${TOP_TLD}.csv"
TOP_SITES_PREFIX='top-sites'
TOP_TLD_PREFIX='top-TLD'

if [ ! -d ${TMP} ]; then
    mkdir -p ${TMP}
else
    rm -rf ${TMP}/*
fi

# Download top 1M and TLDs
download http://s3-us-west-1.amazonaws.com/umbrella-static/top-1m.csv.zip ${TMP}/${TOP_1M_ZIP}
download http://s3-us-west-1.amazonaws.com/umbrella-static/top-1m-TLD.csv.zip  ${TMP}/${TOP_TLD_ZIP}

# Unzip and split files for consumption
unzip ${TMP}/${TOP_1M_ZIP} -d ${TMP}
if [ $? -ne 0 ]; then
    echoerr "Unable to unzip ${TMP}/${TOP_1M_ZIP}"
    exit 4
fi 

unzip ${TMP}/${TOP_TLD_ZIP} -d ${TMP}
if [ $? -ne 0 ]; then
    echoerr "Unable to unzip ${TMP}/${TOP_TLD_ZIP}"
    exit 5
fi 

# Split files for consumption
split_file ${TMP}/${TOP_1M_CSV} ${TMP}/${TOP_SITES_PREFIX}
split_file ${TMP}/${TOP_TLD_CSV} ${TMP}/${TOP_TLD_PREFIX}

# clean-up
find ${TMP}/. ! -name "*.csv" -maxdepth 1 -type f -delete
rm -rf ${TMP}/${TOP_1M_CSV} ${TMP}/${TOP_TLD_CSV}

exit 0
