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
# Auxiliary functions
#

function ada_version() {
    source "$ADA_HOME/bin/ada_general_definitions.txt"
    export ada_version
}

function ada_check_packages() {
    case "$ada_ostype" in
	cygwin)
	    ada_check_packages_cygwin
	    ;;
	linux)
	    ada_check_packages_linux
	    ;;
	macintosh)
	    ada_check_packages_macintosh
	    ;;
    esac
}

function ada_check_packages_cygwin() {
    ada_package_list="coreutils docbook-xml42 docbook-xml43 docbook-xml44 \
                      docbook-xsl file findutils gawk git grep libxml2 \
                      libxslt openssh"
    for pname in $ada_package_list; do
	echo -n "    - Probing package $pname -- "
	if [ `cygcheck -l $pname | wc -l` -eq 0 ]; then
	    echo "MISSING"
	else
	    echo "OK"
	fi
    done
    echo "    (Used command cygcheck -l PKGNAME | wc -l)"
}

function ada_check_packages_linux() {
    ada_package_list="coreutils docbook-xml \
                      docbook-xsl file findutils gawk git grep libxml2 \
                      xsltproc openssh-client"

    # Detect which package management tool is being used
    command=""
    if [ `which dpkg` -a `dpkg -l | wc -l` -ne 0 ]; then
	command="dpkg -s"
    elif [ `which rpm` -a `rpm -l | wc -l` -ne 0 ]; then
	command="rpm -q"
    fi
    for pname in $ada_package_list; do
	echo -n "    - Probing package $pname -- "
	$command $pname 1>/dev/null 2>&1
	if [ $? -ne 0 ]; then
	    echo "MISSING"
	else
	    echo "OK"
	fi
    done
    echo "    (Used command $command)"
}

function ada_check_packages_macintosh() {
    for pname in $ada_package_list; do
	echo -n "    - Probing package $pname -- "
	echo "??"
    done
}

