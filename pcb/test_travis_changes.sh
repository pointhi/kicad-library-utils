#!/bin/bash

# This script file is used to check for error in Pull Requests made on Github
# it loads a list of changed files, and run check_kicad_mod.py on it

PWD_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHECK_KICAD_MOD="$PWD_DIR/check_kicad_mod.py"

# https://docs.travis-ci.com/user/environment-variables/#Default-Environment-Variables

if [ -z ${TRAVIS_COMMIT_RANGE+x} ]
then
	echo -e "\033[0;31m * env variable 'TRAVIS_COMMIT_RANGE' not set\033[0m"
	exit 2;
fi

echo " * check libraries modified in commit range: $TRAVIS_COMMIT_RANGE"

MODIFIED_LIBARIES=`git diff --stat "$TRAVIS_COMMIT_RANGE" | grep -oP '^[[:space:]]*\K.*\.kicad_mod'`

if [ "" == "$MODIFIED_LIBARIES" ]
then
	echo " * no .kicad_mod files were changed"
	exit 0 # nothing to do
fi

echo
echo " * found some .kicad_mod files which changed:"
echo "$MODIFIED_LIBARIES"

echo
echo " * run '$CHECK_KICAD_MOD' for those files"

$CHECK_KICAD_MOD $MODIFIED_LIBARIES

if [ $? -eq 0 ]
then
	echo
	echo -e "\033[0;32m * no errors found\033[0m"
	exit 0; # no errors found
else
	echo
	echo -e "\033[0;31m * errors found\033[0m"
	echo
	echo " please check KiCad Library Convention (https://github.com/KiCad/kicad-library/wiki/Kicad-Library-Convention)"
	echo
	echo " There is also a script which simplify checks of most KLC rules:"
	echo "   kicad-library-utils (https://github.com/KiCad/kicad-library-utils)"
	exit 1; # errors found
fi

