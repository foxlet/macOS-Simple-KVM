set +x;
SCRIPTDIR="$(dirname "$0")";
cd $SCRIPTDIR

echo -ne "\e[1mchecking of pip is installed... \e[0m"
# only try to install pip if it does not exist
if ! hash pip 2>/dev/null; then
	echo ""
	read -p "Do you want me to install pip as root? " yn
	case $yn in
		[Yy]* ) sudo easy_install pip;;
		* ) echo -e "\e[1mplease install pip and try again\e[0m"; exit;;
	esac
else
	echo -e "\e[1m[OK]\e[0m"
fi

echo -e "\e[1mchecking/installing dependencies... \e[0m"
# pip should now exist, only install packages to user home
pip install -r requirements.txt --user
echo -e "\e[1mfechting macOS... \e[0m"

# now that all requirements should be fulfilled, start downloading the image
python fetch-macos.py -p 041-71284 -c DeveloperSeed

echo -e "\e[1mdone\e[0m"
exit;
