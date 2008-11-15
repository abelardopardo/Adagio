#!/bin/bash
#
# Script that given an XML file, it returns the set of files that are included in its
# structure through xi:include elements. The script is recursive because of the
# potentially equally recursive structure of the includes. Once the included
# files are detected (using a stylesheet and catching the xi:include href
# elements), the script is invoked recursively over those that are XML
# files. The result is a space separated list of files on which the given file
# depends.
#
# Due to the fact that the script needs to catch its onwn result in recursive
# calls, it does not print any message.
#

# See where is ADA_HOME
ADA_HOME=`dirname $0`/..
 
# Redirect catalog enquiries to ADA to avoid going out for DTDs
XML_CATALOG_FILES="file://$ADA_HOME/DTDs/catalog"

if [ "$1" = "-cache" ]; then
    if [ "$#" -lt 3 ]; then
	exit
    fi
    shift
    cacheSTR=$1
    shift
    params="$*"
elif [ "$#" -lt 1 ]; then
    exit
else
    params="$*"
fi

idx=0
fileArray=($params)
# Translate each file to absolute path
while [ "$idx" -ne ${#fileArray[*]} ]; do
    fileArray[$idx]=$(cd "$(dirname "${fileArray[$idx]}")"; pwd)/$(basename ${fileArray[$idx]})
    idx=`expr $idx + 1`
done

idx=0
# Loop over all the files in fileArray
while [ "$idx" -ne ${#fileArray[*]} ]; do
    
    # If the file does not exit keep looping
    if [ ! -e ${fileArray[$idx]} ]; then
	idx=`expr $idx + 1`
	continue
    fi

    # If the value is not a file, keep looping
    if [ ! -f "${fileArray[$idx]}" ]; then
	idx=`expr $idx + 1`
	continue
    fi

    # If the file is not an XML file keep looping
#     if [ `file ${fileArray[$idx]} | awk '{ print $2 }'` != "XML" ]; then
    ftest=`file ${fileArray[$idx]}`
    if [ "${ftest/*: XML*/XML}" != "XML" ]; then
	idx=`expr $idx + 1`
	continue
    fi

    # Get the directory prefix of the XML file being processed. This is to
    # prepend to the included files, since their paths are considered from the
    # location of the file containing the includes
    absDir=$(cd "$(dirname "${fileArray[$idx]}")"; pwd)

    # Need this option to detect if anything goes wrong in the pipe execution
    set -o pipefail

    # Execute the stylesheet to fetch the xi:include[@href] elements. Filter out
    # a potential #xpointer suffix in the href attribute and prepend the
    # directory where the source file is located. Also, since the relation
    # between included files is not a tree but a DAG, repeated files need to be
    # filtered (thus the invocation to sort -u)
    files=`xsltproc --nonet $ADA_HOME/ADA_Styles/GetIncludes.xsl ${fileArray[$idx]} 2>> build.out | sed -e 's/#xpointer.*$//g' | sort -u | sed -e "s+^+$absDir/+g"` 

    # If something went wrong, simply bomb out to catch the error in the proper
    # location
    if [ "$?" -ne 0 ]; then
	exit 1
    fi

    if [ "$files" = "" ]; then
	idx=`expr $idx + 1`
	continue
    fi

    for fname in $files; do
	absName=$(cd "$(dirname "$fname")"; pwd)/$(basename $fname)
	echo ${fileArray[*]} | egrep -q "$absName"
	if [ "$?" -eq 1 ]; then
	    fileArray=(${fileArray[*]} $absName)
	fi
    done

    # Advance the index to traverse the array
    idx=`expr $idx + 1`
done

echo ${fileArray[*]}

exit

#    absName=$(cd "$(dirname "$name")"; pwd)/$(basename $name)
