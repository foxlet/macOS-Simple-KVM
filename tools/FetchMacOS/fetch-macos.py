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
__copyright__ = "Copyright 2019, FurCode Project"
__license__ = "GPLv3"
__version__ = "1.4"

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

    @staticmethod
    def fetch_plist(url):
        logging.info("Network Request: %s", "Fetching {}".format(url))
        plist_raw = requests.get(url, headers=ClientMeta.swupdate)
        plist_data = plist_raw.text.encode('UTF-8')
        return plist_data
    
    @staticmethod
    def parse_plist(catalog_data):
        if sys.version_info > (3, 0):
            root = plistlib.loads(catalog_data)
        else:
            root = plistlib.readPlistFromString(catalog_data)
        return root

class SoftwareService:
    # macOS 10.15 is available in 4 different catalogs from SoftwareScan
    catalogs = {
                "10.15": {
                    "CustomerSeed":"https://swscan.apple.com/content/catalogs/others/index-10.15customerseed-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                    "DeveloperSeed":"https://swscan.apple.com/content/catalogs/others/index-10.15seed-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                    "PublicSeed":"https://swscan.apple.com/content/catalogs/others/index-10.15beta-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                    "PublicRelease":"https://swscan.apple.com/content/catalogs/others/index-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
                        },
                "10.14": {
                    "PublicRelease":"https://swscan.apple.com/content/catalogs/others/index-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
                        },
                "10.13": {
                    "PublicRelease":"https://swscan.apple.com/content/catalogs/others/index-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
                        }
                }

    def __init__(self, version, catalog_id):
        self.version = version
        self.catalog_url = self.catalogs.get(version).get(catalog_id)
        self.catalog_data = ""

    def getcatalog(self):
        self.catalog_data = Filesystem.fetch_plist(self.catalog_url)
        return self.catalog_data

    def getosinstall(self):
        # Load catalogs based on Py3/2 lib
        root = Filesystem.parse_plist(self.catalog_data)

        # Iterate to find valid OSInstall packages
        ospackages = []
        products = root['Products']
        for product in products:
            if products.get(product, {}).get('ExtendedMetaInfo', {}).get('InstallAssistantPackageIdentifiers', {}).get('OSInstall', {}) == 'com.apple.mpkg.OSInstall':
                ospackages.append(product)
                
        # Iterate for an specific version
        candidates = []
        for product in ospackages:
            meta_url = products.get(product, {}).get('ServerMetadataURL', {})
            if self.version in Filesystem.parse_plist(Filesystem.fetch_plist(meta_url)).get('CFBundleShortVersionString', {}):
                candidates.append(product)
        
        return candidates


class MacOSProduct:
    def __init__(self, catalog, product_id):
        root = Filesystem.parse_plist(catalog)
        products = root['Products']
        self.date = root['IndexDate']
        self.product = products[product_id]

    def fetchpackages(self, path, keyword=None):
        Filesystem.check_directory(path)
        packages = self.product['Packages']
        if keyword:
            for item in packages:
                if keyword in item.get("URL"):
                    Filesystem.download_file(item.get("URL"), item.get("Size"), path)
        else:
            for item in packages:
                Filesystem.download_file(item.get("URL"), item.get("Size"), path)

@click.command()
@click.option('-o', '--output-dir', default="BaseSystem/", help="Target directory for package output.")
@click.option('-v', '--catalog-version', default="10.15", help="Version of catalog.")
@click.option('-c', '--catalog-id', default="PublicRelease", help="Name of catalog.")
@click.option('-p', '--product-id', default="", help="Product ID (as seen in SoftwareUpdate).")
def fetchmacos(output_dir="BaseSystem/", catalog_version="10.15", catalog_id="PublicRelease", product_id=""):
    # Get the remote catalog data
    remote = SoftwareService(catalog_version, catalog_id)
    catalog = remote.getcatalog()

    # If no product is given, find the latest OSInstall product
    if product_id == "":
        product_id = remote.getosinstall()[0]

    # Fetch the given Product ID
    try:
        product = MacOSProduct(catalog, product_id)
    except KeyError:
        print("Product ID {} could not be found.".format(product_id))
        exit(1)
        
    logging.info("Selected macOS Product: {}".format(product_id))

    # Download package to disk
    product.fetchpackages(output_dir, keyword="BaseSystem")

if __name__ == "__main__":
    fetchmacos()
