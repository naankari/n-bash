#!/bin/bash



branch=${1-master}

nHome="$HOME/.n"
masterSwitchFile="$HOME/n-bash-on-off"

archiveLocation="https://github.com/naankari/n-bash/archive/$branch.zip"

downloadAs="/tmp/n-bash-$branch.zip"
extractionDir="/tmp/n-bash-$branch-zip"

targetDirectory="$nHome/scripts"
archiveContainerDirectory="n-bash-$branch/scripts"

echo "Setting up nBash ..."

targetDirectory="$nHome/scripts"
if [[ -d $targetDirectory ]]; then
	echo -e "\n\nTarget directory $targetDirectory already exists. It will be backed up and deleted."
	echo "Enter 'y' or 'yes' to continue:"
	read input
	input=${input^^}
	if [[ $input != "Y" && $input != "YES" ]]; then
		echo "Exiting."
		exit 1
	fi
	backupLocation="${targetDirectory}.bak"
	echo "Creating backup of $targetDirectory at $backupLocation"
	if [[ ! -d $backupLocation ]]; then
		mkdir -p $backupLocation
	fi
	cp -r "${targetDirectory}"/* "$backupLocation"
fi

echo -e "\n\nDownloading archive from $archiveLocation as $downloadAs ..."
rm -rf "$downloadAs"
wget -O "$downloadAs" "$archiveLocation"

echo -e "\n\nExtracing archive $downloadAs in $extractionDir ..."
rm -rf "$extractionDir"
unzip $downloadAs -d "$extractionDir"

echo -e "\n\nMoving contents from $extractionDir/$archiveContainerDirectory to $targetDirectory ..."
mkdir -p $targetDirectory
mv "$extractionDir/$archiveContainerDirectory"/* "$targetDirectory/"
echo "Done copying files."

echo -e "\n\nCreating master switch file to turn on/off nBash?"
echo "Enter 'n' or 'no' to skip:"
read input
input=${input^^}
if [[ $input = "N" || $input = "NO" ]]; then
	echo "Not creaing master switch file."
else
	echo "on" > $masterSwitchFile
	echo "Created file $masterSwitchFile. To turn off nBash, write 'off' in the file."
fi

echo -e "\n\nWrite following lines to your profile:"
echo -e "[Important: Its always better to put this on top.]\n\n"
echo "################ SETTING UP N BASH ################"
echo "#################### FROM HERE ####################"
echo "export N_HOME=\"$nHome\""
echo "source \"$nHome/n.sh\""
echo "#################### TILL HERE ####################"

echo -e "\n\nnBash setup completed."
