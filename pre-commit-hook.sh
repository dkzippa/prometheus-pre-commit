#!/bin/sh

set -e

### uncomment to debug
# set -x 



######## VARIABLES #########
TMP_DIR=/tmp/gitleaks-tmp
BIN_DIR=../../bin
GO_APP=go
WGET_APP=wget
GITLEAKS_APP_NAME=gitleaks
GITLEAKS_APP_PATH=$GITLEAKS_APP_NAME
RELEASES_URL=https://api.github.com/repos/gitleaks/gitleaks/releases/latest
SCRIPT_NAME=pre-commit-hook.sh

######## ASSIGN #########

OS=$(uname)
ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" ]]; then
	ARCH="arm64";
fi
if [[ "$ARCH" == "x86_64" ]]; then
	ARCH="amd64";
fi

if [ -f "${BIN_DIR}/${GITLEAKS_APP_NAME}" ]; then
	GITLEAKS_APP_PATH="${BIN_DIR}/${GITLEAKS_APP_NAME}"
fi



function run_gitleaks {
    $GITLEAKS_APP_PATH protect --verbose --redact --staged
}


function download_binary_release {

	if type -P $WGET_APP; then 

		RELEASE_URL=`echo $RELEASE_RECORD| awk -F'"' '{print $4}'`
		echo "Release url: ${RELEASE_URL}"

		mkdir -p $TMP_DIR
		wget -P $TMP_DIR $RELEASE_URL    

		RELEASE_FILE=`echo $RELEASE_URL| awk -F'/' '{print $NF}'`
		echo "Release file: ${RELEASE_FILE}"

		tar -zxvf "${TMP_DIR}/${RELEASE_FILE}" -C $TMP_DIR

	else
		echo ""    
		echo "WGET could not be found. Please install."    
		echo ""
		exit 1
	fi		

}



function compile_from_sources {
	echo "Compile Gitleaks sources"

	if type -P $GO_APP; then 
		git clone https://github.com/gitleaks/gitleaks.git $TMP_DIR
		COMPILE=`cd $TMP_DIR && make build` 

		copy_app_from_tmp 
		
	else
		echo ""    
		echo "GO could not be found. Please install to compile the Gitleaks sources"    
		echo ""
		exit 1
	fi		
}



# copy binary to repo/bin folder and use in pre-commit
function copy_app_from_tmp {

	mkdir -p $BIN_DIR
	
	yes | cp -rf "${TMP_DIR}/${GITLEAKS_APP_NAME}" "${BIN_DIR}/${GITLEAKS_APP_NAME}"
	
	GITLEAKS_APP_PATH="${BIN_DIR}/${GITLEAKS_APP_NAME}"
	echo "GITLEAKS_APP_PATH: ${GITLEAKS_APP_PATH}"		

	chmod +x $GITLEAKS_APP_PATH
	
	echo ""
	echo "Gitleaks installation to repo/bin folder is complete."
	echo ""		
}


#  get binary from the latest release for os and arch, or build from go sources if release does not exists
function install_gitleaks {

    echo ""
    echo "install Gitleaks on ${OS} ${ARCH}"
    echo ""

    RELEASE_RECORD=`curl -L -H "Accept: application/vnd.github+json" $RELEASES_URL | grep browser_download_url | grep -i $OS | grep -i $ARCH | head -n 1` 

	# if no release for the os and arch, build from sources
	if [[ -z "$RELEASE_RECORD" ]]; then

		compile_from_sources

	# if there is release for the os and arch, download and use the binary
	else

		download_binary_release

		copy_app_from_tmp
	fi

	# cleanup 
	if [ -d "$TMP_DIR" ]; then rm -Rf $TMP_DIR; fi

}



main() {
	# check if it install or regular run
	if ! [ -z "$1" ] && [ "$1" == "install" ]; then
		
		if [ -d .git/hooks ]; then

			# # check if pre-commit hook exists already
			# if [ -f .git/hooks/pre-commit ]; then
			# 	echo "There is pre-commit hook already. Do you wish to overwrite it? (y/n) "


			# 	while true; do
			# 		read -p "There is pre-commit hook already. Do you wish to overwrite it? (y/n) " yn
			# 		case $yn in
			# 			[Yy]* ) yes | cp -rf $SCRIPT_NAME ".git/hooks/pre-commit"; break;;
			# 			[Nn]* ) exit;;
			# 			* ) echo "Please answer yes or no.";;
			# 		esac
			# 	done			


			# else 
			# 	cp $SCRIPT_NAME ".git/hooks/pre-commit"
			# fi	

			cp -rf $SCRIPT_NAME ".git/hooks/pre-commit"
			echo "Pre-commit hook installed."	
					
		else
			echo "Not a git repo."
			exit 1
		fi

		chmod +x ".git/hooks/pre-commit"

	else
		# check  user.gitleaks-enable
		PRECOMMIT_ENABLED=$(git config --get --default 1 --int user.gitleaks-enable);
		echo ""
		echo "Gitleaks pre-commit enabled: $PRECOMMIT_ENABLED"
		echo ""

		if [ $PRECOMMIT_ENABLED -eq 1 ]; then

			if  type -P $GITLEAKS_APP_NAME || [ -f "${BIN_DIR}/${GITLEAKS_APP_NAME}" ]; then    		
				run_gitleaks
			else
				echo ""    
				echo "Gitleaks not found in \$PATH. Installling..."    
				echo ""    
				install_gitleaks && run_gitleaks
			fi
		else
			exit 0;
		fi	
	fi
}

main "$@"