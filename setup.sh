#!/bin/bash



branch=${1-master}

nHome="$HOME/.n"
archiveLocation="https://github.com/naankari/n-bash/archive/$branch.zip"
archiveContainerDirectory="n-bash-$branch/scripts"

downloadAs="/tmp/n-bash-$branch.zip"
extractionDir="/tmp/n-bash-$branch-zip"

masterSwitchFile="$HOME/n-bash-on-off"

echo "Setting up nBash ..."

if [[ -d $nHome ]]; then
	echo -e "\n\nTarget directory $nHome already exists. Some files will be overwritten."
	echo "Enter 'y' or 'yes' to continue:"
	read input
	input=${input^^}
	if [[ $input != "Y" && $input != "YES" ]]; then
		echo "Exiting."
		exit 1
	fi
	backupLocation="${nHome}.bak"
	echo "Creating backup of $nHome at $backupLocation"
	if [[ ! -d $backupLocation ]]; then
		mkdir -p $backupLocation
	fi
	cp -r "${nHome}"/* "$backupLocation"
fi

echo -e "\n\nDownloading archive from $archiveLocation as $downloadAs ..."
rm -rf "$downloadAs"
wget -O "$downloadAs" "$archiveLocation"

echo -e "\n\nExtracing archive $downloadAs in $extractionDir ..."
rm -rf "$extractionDir"
unzip $downloadAs -d "$extractionDir"

echo -e "\n\nMoving contents from $extractionDir/$archiveContainerDirectory to $nHome ..."
mv "$extractionDir/$archiveContainerDirectory"/* "$nHome/"
echo "Done copying files."

echo -e "\n\nDo you want to create master switch file to turn on/off nBash?"
echo "Enter 'y' or 'yes' to okay:"
read input
input=${input^^}
if [[ $input = "Y" || $input = "YES" ]]; then
	comment=""
	echo "ON" > $masterSwitchFile
	echo "Created file $masterSwitchFile. To turn off nBash, write 'off' in the file."
else
	echo "Not creaing master switch file."
fi

echo -e "\n\nWrite following lines to your profile:"
echo -e "[Important: Its always better to put this on top.]\n\n"
echo "#################### FROM HERE ####################"
echo "export N_HOME=\"$nHome\""
echo "source \"$nHome/n.sh\""
echo "#################### TILL HERE ####################"

echo -e "\n\nnBash setup completed."
