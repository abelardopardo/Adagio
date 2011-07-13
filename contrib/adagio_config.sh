#!/bin/bash

# This script configures the user account of an instructor in order
# to begin to contribute to an Adagio course material repository.
# It is mostly useful when a virtual machine is distributed to instructors,
# and the instructor needs to be personalize it for him (mainly setting
# up his identity in the git repository).
#
# A config file name .adagio_init.conf is assumed to be in the $HOME
# directory of the user, with a format like the following example (the
# "#" character at the beginning of the line must not be in the file):
#
# --BEGIN-EXAMPLE
# adagio-repository: http://www.github.com/abelardopardo/Adagio
# adagio-local-dir: Adagio
# course-repository: mycourse@host.example.com:adagio/MyCourseMaterials
# course-local-dir: MyCourseMaterials
# message: This script will configure your virtual machine to
# message: work with MyCourse materials. It expects you to enter
# message: some information, including your user id in the institution.
# --END-EXAMPLE
#
# adagio-local-dir and course-local-dir may be absolute paths, or
# paths relative to $HOME.
#
# The creator of the virtual machine should create that file before
# distributing it to the instructors.
#
# When the script is run it will:
#
#- Ask for the user full name, account name and e-mail. Those values
# will be added to the $HOME/.gitconfig file and to a "push" clause in
# the course git repository, so that changes uploaded with git-push
# are stored in a branch with the same name as the account name of the
# user. Warning: $HOME/.gitconfig will be overwritten by this script!!
#
#- Clone the course repository, in course_local_dir from the config
# file. To avoid network traffic, the creator of the virtual machine
# may clone it before distribution. In that case, the repository is
# just updated by the script. In both cases, .git/config in the
# repository is overwritten.
#
# - Clone the Adagio repository in adagio_local_dir. To avoid network
# traffic, the creator of the virtual machine may clone it before
# distribution. In that case, the repository is just updated by the
# script.
#
# Copyright (C) 2010 Carlos III University of Madrid
# This file is part of Adagio: Agile Distributed Authoring Integrated Toolkit

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
# Author: Jesús Árias Fisteus(jaf@it.uc3m.es)
#

CONFFILE=$HOME/.adagio_init.conf

if [ ! -r $CONFFILE ]
then
    echo "Error: file $CONFFILE/.adagio_init.conf not found or not readable"
    exit 1
fi

grep $HOME/.adagio_init.conf -e "^message:" | cut -d: -f 2-
echo
echo "Enter your name, user id and email address."

correct="No"
while [ $correct == "No" ]
do
    read -p "Full name: " fullname
    read -p "User id: " usrname
    read -p "Email address (p.e. nobody@example.com): " email
    echo
    echo "Full name: $fullname"
    echo "User id: $usrname"
    echo "Email: \"$fullname\" <$email>"
    read -p "Is that correct (y/n)? " correct_text
    if [ $correct_text == "y" ]
    then
	correct="Yes"
    else
	echo "Please, try again"
    fi
done

echo

# Read config files; assignment through intermediate variable data
# to trim whitespaces
data=`cat $CONFFILE | grep ^course-repository | cut -d ':' -f 2-`
course_repo=`echo $data`
data=`cat $CONFFILE | grep ^course-local-dir | cut -d ':' -f 2-`
course_dir=`echo $data`
data=`cat $CONFFILE | grep ^adagio-repository | cut -d ':' -f 2-`
adagio_repo=`echo $data`
data=`cat $CONFFILE | grep ^adagio-local-dir | cut -d ':' -f 2-`
adagio_dir=`echo $data`

if [[ x$course_repo == x || x$adagio_repo == x ]]
then
    echo "Course repository or Adagio repository missing in config file"
    exit 2
fi

if [[ x$course_dir == x || x$adagio_dir == x ]]
then
    echo "Course directory or Adagio directory missing in config file"
    exit 2
fi

pushd $HOME

if [[ x$course_dir != x && -d $course_dir ]]
then
    echo "Updating the course repository at $course_dir"
    pushd $course_dir
    if ! git pull
    then
	echo "Error in git pull. Course repository not updated"
	popd; popd
	exit 4
    fi
    popd
else
    echo "Cloning the course repository. It may take a while..."
    pwd
    echo git clone $course_repo $course_dir
    if ! git clone $course_repo $course_dir
    then
	echo "Error in git clone. Course repository not cloned"
	popd
	exit 3
    fi
fi
cat >$course_dir/.git/config <<EOF
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote "origin"]
	fetch = +refs/heads/*:refs/remotes/origin/*
	url = $course_repo
	push = master:$usrname
[branch "master"]
	remote = origin
	merge = refs/heads/master
EOF

cat >$HOME/.gitconfig <<EOF
[user]
        name = $fullname
        email = $email
[color]
	branch = auto
	diff = auto
	status = auto
[color "branch"]
       current = yellow reverse
       local = yellow
       remote = green
[color "diff"]
       meta = yellow bold
       frag = magenta bold
       old = red bold
       new = blue bold
[color "status"]
       added = yellow
       changed = green
       untracked = cyan
EOF

if [[ x$adagio_dir != x && -d $adagio_dir ]]
then
    echo "Updating the Adagio repository at $adagio_dir"
    pushd $adagio_dir
    if ! git pull
    then
	echo "Error in git pull. Adagio repository not updated"
	popd; popd
	exit 6
    fi
    popd
else
    echo "Cloning the Adagio repository. It may take a while..."
    if ! git clone $adagio_repo $adagio_dir
    then
	echo "Error in git clone. Adagio repository not cloned"
	popd
	exit 5
    fi
fi

echo
echo "The system has been successfully configured."
echo "The course repository and the Adagio repository are up to date."

popd
