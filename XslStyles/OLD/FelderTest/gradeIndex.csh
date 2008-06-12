#!/bin/csh
#
# Script to traverse the list of sub.* dirs and create an HTML page to access them
#
# $1: Must be the directory where the Felder/index.xml is with the text describing
#     the test. Mandatory
# $2: Optional. The filename where to dump the result
#
if ( "$1" == "" ) then
  echo "ERROR: Missing dir where the index.xml is located."
  exit
else
  if ( ! -erd "$1" ) then
    echo "ERROR: $1 must be a directory with read permission."
    exit
  endif
endif
set srcDir="$1"

# File to dump the result
if ( "$2" != "" ) then
  set outputFile="$2"
else
  set outputFile="submissionlist.xml"
endif

rm -f  $outputFile
echo '<?xml version="1.0" encoding="ISO-8859-1"?>' >>& $outputFile
echo '' >>& $outputFile
echo '<\!DOCTYPE chapter PUBLIC "-//OASIS//DTD DocBook XML V4.2//EN"' >>& $outputFile
echo '"http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd">' >>& $outputFile
echo '' >>& $outputFile
echo '<chapter lang="es">' >>& $outputFile
echo '  <xi:include href="'$srcDir'/index.xml" parse="xml"' >>& $outputFile
echo '    xpointer="xpointer(/chapter/title)"' >>& $outputFile
echo '    xmlns:xi="http://www.w3.org/2001/XInclude"/>' >>& $outputFile

set sublist=`find . -maxdepth 1 -mindepth 1 -name 'sub.*' -type d | sort -r`
if ( "$sublist" == "" ) then
echo '</chapter>' >>& $outputFile
  exit
endif

echo '  <itemizedlist>' >>& $outputFile

foreach subname ( $sublist )
    echo "Processing $subname"
echo '    <listitem>' >>& $outputFile
echo '      <para>' >>& $outputFile
echo '        <ulink url="'$subname/results.html'">'`basename $subname`'</ulink>' >>& $outputFile
echo '      </para>' >>& $outputFile
echo '    </listitem>' >>& $outputFile
end

echo '  </itemizedlist>' >>& $outputFile

echo '</chapter>' >>& $outputFile
