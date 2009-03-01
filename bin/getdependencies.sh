#!/bin/bash
#
# Copyright (C) 2008 Carlos III University of Madrid
# This file is part of the ADA: Agile Distributed Authoring Toolkit

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor
# Boston, MA  02110-1301, USA.

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
	echo "ADA Internal error. Inconsisten use 1 of getdependencies" >>$originDir/build.out
	exit -1
    fi
    shift
    cacheSTR=$1
    shift
    params="$*"
elif [ "$#" -lt 1 ]; then
    echo "ADA Internal error. Inconsisten use 2 of getdependencies" >>$originDir/build.out
    exit -1
else
    params="$*"
fi

# Remember the
originDir=`pwd`

idx=0
fileArray=($params)

# Translate each file to absolute path
while [ "$idx" -ne ${#fileArray[*]} ]; do
    if [ -e "${fileArray[$idx]}" ]; then
	# If it exists in the current dir, transform to absolute path
	fileArray[$idx]=$(cd "$(dirname "${fileArray[$idx]}")"; pwd)/$(basename ${fileArray[$idx]})
    elif [ -e "$ADA_HOME/ADA_Styles/${fileArray[$idx]}" ]; then
	# If not in current dir, check ADA_Styles (used by default) and
	# translate again to absolute path
	fileArray[$idx]="$ADA_HOME/ADA_Styles/${fileArray[$idx]}"
    else
	# It not in current dir nor in the ADA_Styles, bomb out
	echo "File ${fileArray[$idx]} (given as argument to getdependencies) does not exist." >>$originDir/build.out
	exit -1
    fi
    idx=`expr $idx + 1`
done

idx=0
# Loop over all the names in fileArray
while [ "$idx" -ne ${#fileArray[*]} ]; do

    # Restore the dir where the script started
    cd $originDir

    # If the value is not a file, keep looping
    if [ ! -f "${fileArray[$idx]}" ]; then
	idx=`expr $idx + 1`
	continue
    fi

    # If the file is not an XML file keep looping
    ftest=`file ${fileArray[$idx]}`
    if [ "${ftest/*: XML*/XML}" != "XML" ]; then
	idx=`expr $idx + 1`
	continue
    fi

    # Get the directory prefix of the XML file being processed. This is to
    # prepend to the included files, since their paths are considered from the
    # location of the file containing the includes
    absDir=$(cd "$(dirname "${fileArray[$idx]}")"; pwd)
    cd $absDir

    # Need this option to detect if anything goes wrong in the pipe execution
    set -o pipefail

    # Remember if build.out is present before executing this command
    test -f $originDir/build.out
    buildNotPresent=$?

    # Execute the stylesheet to fetch the xi:include[@href] elements. Filter out
    # a potential #xpointer suffix in the href attribute. Also, since the
    # relation between included files is not a tree but a DAG, repeated files
    # need to be filtered (thus the invocation to sort -u)
    files=`xsltproc --path .:$ADA_HOME/ADA_Styles --nonet $ADA_HOME/ADA_Styles/GetIncludes.xsl ${fileArray[$idx]} 2>> $originDir/build.out | sed -e 's/#xpointer.*$//g' | sort -u `

    # If something went wrong, simply bomb out to catch the error in the proper
    # location
    if [ "$?" -ne 0 ]; then
	echo "ADA detected the incorrect XML file: ${fileArray[$idx]}" >> $originDir/build.out
	exit -1
    else
	# If build.out was not present, and now it is empty, nuke it
	if [ "$buildNotPresent" = "1" -a ! -s $originDir/build.out ]; then
	    rm -f $originDir/build.out
	fi
    fi


    # If there are no files included, keep looping
    if [ "$files" = "" ]; then
	idx=`expr $idx + 1`
	continue
    fi

    # Process each file included to include them in the Array
    for fname in $files; do

	# If the file does not exist in current dir nor ADA_Styles, bomb out
	if [ ! -e $fname -a ! -e $ADA_HOME/ADA_Styles/$fname ]; then
	    echo "File $fname (included in ${fileArray[$idx]}), does not exist" >>$originDir/build.out
	    exit -1
	fi

	# Process the file depending if it is in ADA_Styles
	if [ -e $ADA_HOME/ADA_Styles/$fname ]; then
	    absName="$ADA_HOME/ADA_Styles/$fname"
	else
	    # Create the absolute name of the file
	    absName=$(cd "$(dirname "$fname")"; pwd)/$(basename $fname)
	fi

	# Check if it is already in the result
	echo ${fileArray[*]} | egrep -q "$absName"

        # If not in the result, insert it
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
