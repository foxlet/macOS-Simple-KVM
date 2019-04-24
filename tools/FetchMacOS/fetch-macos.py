#!/usr/bin/python

"""fetch-macos.py: Fetches macOS products from Apple's SoftwareUpdate service."""

import logging
import plistlib
import os
import errno
import click
import requests
import sys

__author__ = "Foxlet"
__copyright__ = "Copyright 2018, FurCode Project"
__license__ = "GPLv3"
__version__ = "1.2"

logging.basicConfig(format='%(asctime)-15s %(message)s', level=logging.INFO)
logger = logging.getLogger('webactivity')


class ClientMeta:
    # Client used to connect to the Software CDN
    osinstall = {"User-Agent":"osinstallersetupplaind (unknown version) CFNetwork/720.5.7 Darwin/14.5.0 (x86_64)"}
    # Client used to connect to the Software Distribution service
    swupdate = {"User-Agent":"Software%20Update (unknown version) CFNetwork/807.0.1 Darwin/16.0.0 (x86_64)"}


class Filesystem:
    @staticmethod
    def download_file(url, size, path):
        label = url.split('/')[-1]
        filename = os.path.join(path, label)
        # Set to stream mode for large files
        remote = requests.get(url, stream=True, headers=ClientMeta.osinstall)

        with open(filename, 'wb') as f:
            with click.progressbar(remote.iter_content(1024), length=size/1024, label="Fetching {} ...".format(filename)) as stream:
                for data in stream:
                    f.write(data)
        return filename

    @staticmethod
    def check_directory(path):
        try:
            os.makedirs(path)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                raise


class SoftwareService:
    # macOS 10.14 ships in 4 different catalogs from SoftwareScan
    catalogs = {"CustomerSeed":"https://swscan.apple.com/content/catalogs/others/index-10.14customerseed-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                "DeveloperSeed":"https://swscan.apple.com/content/catalogs/others/index-10.14seed-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                "PublicSeed":"https://swscan.apple.com/content/catalogs/others/index-10.14beta-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                "PublicRelease":"https://swscan.apple.com/content/catalogs/others/index-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"}

    def __init__(self, catalog_id):
        self.catalog_url = self.catalogs.get(catalog_id, self.catalogs["PublicRelease"])
        self.catalog_data = ""

    def getcatalog(self):
        logging.info("Network Request: %s", "Fetching {}".format(self.catalog_url))
        catalog_raw = requests.get(self.catalog_url, headers=ClientMeta.swupdate)
        self.catalog_data = catalog_raw.text.encode('UTF-8')
        return catalog_raw.text.encode('UTF-8')

    def getosinstall(self):
        if (sys.version_info > (3, 0)):
            root = plistlib.readPlistFromBytes(self.catalog_data)
        else:
            root = plistlib.readPlistFromString(self.catalog_data)
        products = root['Products']
        for product in products:
                if 'ExtendedMetaInfo' in products[product]:
                    IAMetaInfo = products[product]['ExtendedMetaInfo']
                    if 'InstallAssistantPackageIdentifiers' in IAMetaInfo:
                        IAPackageID = IAMetaInfo['InstallAssistantPackageIdentifiers']
                        if IAPackageID['OSInstall'] == 'com.apple.mpkg.OSInstall':
                            return product


class MacOSProduct:
    def __init__(self, catalog, product_id):
        if (sys.version_info > (3, 0)):
            root = plistlib.readPlistFromBytes(catalog)
        else:
            root = plistlib.readPlistFromString(catalog)
        products = root['Products']
        self.date = root['IndexDate']
        self.product = products[product_id]

    def fetchpackages(self, path):
        Filesystem.check_directory(path)
        packages = self.product['Packages']
        for item in packages:
            if "BaseSystem" in item.get("URL"):
                Filesystem.download_file(item.get("URL"), item.get("Size"), path)


@click.command()
@click.option('-o', '--output-dir', default="BaseSystem/", help="Target directory for package output.")
@click.option('-c', '--catalog-id', default="PublicRelease", help="Name of catalog.")
@click.option('-p', '--product-id', default="", help="Product ID (as seen in SoftwareUpdate).")
@click.option('-l', '--latest', is_flag=True, help="Get latest available macOS package.")
def fetchmacos(output_dir="BaseSystem/", catalog_id="PublicRelease", product_id="", latest=False):
    # Get the remote catalog data
    remote = SoftwareService(catalog_id)
    catalog = remote.getcatalog()

    # Get the current macOS package
    if latest:
        product_id = remote.getosinstall()
    else:
        if product_id == "":
            print("You must provide a Product ID (or pass the -l flag) to continue.")
            exit(1)
        product_id = product_id
    try:
        update = MacOSProduct(catalog, product_id)
    except KeyError:
        print("Product ID {} could not be found.".format(product_id))
        exit(1)
    logging.info("Selected macOS Product: {}".format(product_id))

    # Download package to disk
    update.fetchpackages(output_dir)

if __name__ == "__main__":
    fetchmacos()
