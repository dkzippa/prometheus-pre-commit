#!/bin/bash

set -e

### uncomment to debug
# set -x 


TARTET_FILE=".git/hooks/pre-commit"
SRC_FILE="https://raw.githubusercontent.com/dkzippa/prometheus-pre-commit-hook/main/pre-commit-hook"

main() {

	if [ -d .git/hooks ]; then

		# # check if pre-commit hook exists already
		# if [ -f .git/hooks/pre-commit ]; then
		# 	echo "There is pre-commit hook already. Do you wish to overwrite it? (y/n) "


		# 	while true; do
		# 		read -p "There is pre-commit hook already. Do you wish to overwrite it? (y/n) " yn
		# 		case $yn in
		# 			[Yy]* ) curl -o $TARTET_FILE $SRC_FILE; break;;
		# 			[Nn]* ) exit;;
		# 			* ) echo "Please answer yes or no.";;
		# 		esac
		# 	done			

		# else 
		# 	curl -o $TARTET_FILE $SRC_FILE
		# fi	

		curl -o $TARTET_FILE $SRC_FILE
		echo "Pre-commit hook installed."	
				
	else
		echo "Not a git repo."
		exit 1
	fi

	chmod +x $TARTET_FILE

}

main "$@"