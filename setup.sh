branch=${1-master}

nHome="$HOME/.n"
archiveLocation="https://github.com/naankari/n-bash/archive/$branch.zip"
archiveContainerDirectory="n-bash-$branch/scripts"

downloadAs="/tmp/n-bash-$branch.zip"
extractionDir="/tmp/n-bash-$branch-zip"

if [[ -d $nHome ]]; then
	echo "Target directory $nHome already exists. Please remove it yourself."
	exit 1
fi

echo "Downloading archive from $archiveLocation as $downloadAs ..."
rm -rf "$downloadAs"
wget -O "$downloadAs" "$archiveLocation"

echo "Extracing archive $downloadAs in $extractionDir ..."
rm -rf "$extractionDir"
unzip $downloadAs -d "$extractionDir"

echo "Moving contents from $extractionDir/$archiveContainerDirectory to $nHome ..."
mv "$extractionDir/$archiveContainerDirectory" "$nHome"

echo "Done copying files."

echo "Write folliwng lines to your profile:"
echo "[Important: Its always better to put this on top.]"
echo "#################### FROM HERE ####################"
echo "export N_HOME=\"$nHome\""
echo "source \"$nHome/n.sh\""
echo "#################### TILL HERE ####################"

