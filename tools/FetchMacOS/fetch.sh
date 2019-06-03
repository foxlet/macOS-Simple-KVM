set +x;
SCRIPTDIR="$(dirname "$0")";
cd $SCRIPTDIR
sudo easy_install pip
sudo -H pip install -r requirements.txt
python fetch-macos.py -p 041-71284 -c DeveloperSeed
exit;
