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
# The weak point of this script is that the structure of included files is in
# fact a DAG which needs to be traversed. The ideal implementation
# would require an associative table (or a cache) to store the previously traversed
# files and their results. That way, whenever the same file is visited, the
# script cuts the recursion (Complexity O(m) where m is the number of files)
#
# I have no idea how to use associative arrays in bash, and since ADA needs to
# work in a minimal environment, using Python, Perl or any other scripting
# language is out of the questtion. As a consequence, a less than
# than ideal processing algorithm follows.
#

# The script must have a single argument and must be an XML file. If empty, return
if [ "$1" = "" ]; then
  exit
fi

# If the argument is not a file, terminate
if [ ! -f "$1" ]; then
  exit
fi

# If the file is not an XML file terminate
if [ `file $1 | awk '{ print $2 }'` != "XML" ]; then
  exit
fi

# See where is ADA_HOME
ADA_HOME=`dirname $0`/..

# Get the directory prefix of the XML file being processed. This is to prepend
# to the included files, since their paths are considered from the location of
# the file containing the includes
xmldir=`dirname $1`

# Execute the stylesheet to fetch the xi:include[@href] elements. Filter out a
# potential #xpointer suffix in the href attribute and prepend the directory
# where the source file is located. Also, since the relation between included
# files is not a tree but a DAG, repeated files need to be filtered (thus the
# invocation to sort -u)
files=`xsltproc $ADA_HOME/XslStyles/GetIncludes.xsl $1 | sed -e 's/#xpointer.*$//g' | sort -u | sed -e "s+^+$xmldir/+g"` 

# If the file has no relevant includes, we are done
if [ "$files" = "" ]; then
  exit
fi

# Accumulate the result in the variable finalfiles
finalfiles="$files"

# Loop over each obtained file to invoke the script recursively
for fname in $files; do

    # Although the script checks for the file being of type XML, the check at
    # this point saves the recursive invokation.
    if [ `file $1 | awk '{ print $2 }'` = "XML" ]; then
	# Recursive invocation of the script
	recursivefiles=`getdependencies.sh $fname`
	
	# Accumulate the obtained files.
	finalfiles="$finalfiles $recursivefiles"
    fi
done

# The check for redundant filenames is done only at the level of the includes of
# each file separatedly, a new check needs to be done for all the resulting files
finalfiles=`echo $finalfiles | sed -e 's/ +/\n/g' | sort -u`

files="$finalfiles"
finalfiles=""
for name in $files; do
  finalfiles="$finalfiles $name"
done

echo $finalfiles
