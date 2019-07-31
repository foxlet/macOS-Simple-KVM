#!/usr/bin/python

"""fetch-macos.py: Fetches macOS products from Apple's SoftwareUpdate service."""

import logging
import plistlib
import os
import errno
import click
import requests
import sys
import re

__author__ = "Foxlet"
__copyright__ = "Copyright 2019, FurCode Project"
__license__ = "GPLv3"
__version__ = "1.3"

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
    # macOS 10.15 is available in 4 different catalogs from SoftwareScan
    catalogs = {"CustomerSeed":"https://swscan.apple.com/content/catalogs/others/index-10.15customerseed-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                "DeveloperSeed":"https://swscan.apple.com/content/catalogs/others/index-10.15seed-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                "PublicSeed":"https://swscan.apple.com/content/catalogs/others/index-10.15beta-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                "PublicRelease":"https://swscan.apple.com/content/catalogs/others/index-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                "PublicRelease14":"https://swscan.apple.com/content/catalogs/others/index-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog",
                "PublicRelease13":"https://swscan.apple.com/content/catalogs/others/index-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"}

    def __init__(self, catalog_id):
        self.catalog_data = list()
        self.catalog_url = list()

        if catalog_id == "__ALL__":
            # Automatically generate each version's catalog URL from the latest
            match = re.match(r'(https://swscan.apple.com/content/catalogs/others/index-)([\w.-]+)(\.merged-1\.sucatalog)', self.catalogs.get("DeveloperSeed"))
            releases = match.group(2).split('-')
            for i in range(len(releases)):
                self.catalog_url.append(match.group(1) + str().join([x + '-' for x in releases]).rstrip('-') + match.group(3))
                releases.remove(releases[0])
        else:
            self.catalog_url.append(self.catalogs.get(catalog_id))

    def getcatalogs(self):
        self.catalog_raw = list()
        for url in self.catalog_url:
            logging.info("Network Request: %s", "Fetching {}".format(url))
            self.catalog_raw.append(requests.get(url, headers=ClientMeta.swupdate))

        self.catalog_data = [datum.text.encode('UTF-8') for datum in self.catalog_raw]
        return self.catalog_data

    def getosinstall(self):
        # Load catalogs based on Py3/2 lib
        roots = list()
        for index, datum in enumerate(self.catalog_data):
            if sys.version_info > (3, 0):
                # Ignore any missing/corrupted catalogs
                try:
                    roots.append(plistlib.loads(datum))
                except plistlib.InvalidFileException:
                    logging.warning("Catalog at {} corrupted or missing, contents won't be downloaded.".format(self.catalog_url[index]))
            else:
                roots.append(plistlib.readPlistFromString(datum))

        # Iterate to find valid OSInstall packages
        ospackages = list()
        for root in roots:
            products = root['Products']
            for product in products:
                if products.get(product, {}).get('ExtendedMetaInfo', {}).get('InstallAssistantPackageIdentifiers', {}).get('OSInstall', {}) == 'com.apple.mpkg.OSInstall':
                    ospackages.append(product)
        return ospackages


class MacOSProduct:
    def __init__(self, catalog, product_id):
        if sys.version_info > (3, 0):
            root = plistlib.loads(catalog)
        else:
            root = plistlib.readPlistFromString(catalog)
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
@click.option('-a', '--fetch-all', is_flag=True, help="Get all available macOS packages. Implies --package=\"__ALL__\", --catalog-id=\"__ALL__\", and --output-dir=\"SoftwareUpdate\". Conflicts with -l.")
@click.option('-l', '--latest', is_flag=True, help="Get latest available macOS package. Conflicts with -a.")
@click.option('-c', '--catalog-id', default="PublicRelease", help="Name of catalog. Specify \"__ALL__\" to attempt to fetch all catalogs.")
@click.option('-p', '--product-id', default="", help="Product ID (as seen in SoftwareUpdate).")
@click.option('-k', '--package', default="BaseSystem", help="Package keyword (as seen in SoftwareUpdate). Specify \"__ALL__\" a package to download all packages. Defaults to BaseSystem for backwards compatibility.")
def fetchmacos(output_dir="BaseSystem", catalog_id="PublicRelease", product_id="", latest=False, fetch_all=False, package="BaseSystem"):
    # Apply implicit options of --fetch-all
    if fetch_all:
        output_dir="SoftwareUpdate"
        catalog_id="__ALL__"
        package=None

    # Get the remote catalog data
    remote = SoftwareService(catalog_id)
    catalogs = remote.getcatalogs()

    # Ensure there's no conflicting flags
    if latest and fetch_all:
        print("You can only provide ONE OF the -l or -a flags, NOT both.")
        exit(1)
    # If latest is used, find the latest OSInstall package
    elif latest:
        product_id = remote.getosinstall()[0][-1]
    # If fetch_all is used, find ALL the OSInstall packages
    elif fetch_all:
        logging.info("Selected ALL macOS Products")
        for catalog in catalogs:
            for product in remote.getosinstall():
                print("Downloading product: {}".format(product))
                p = MacOSProduct(catalog, product)
                p.fetchpackages(os.path.join(output_dir, product))
        exit(0)
    elif product_id:
        # Fetch the given Product ID
        try:
            product = MacOSProduct(catalogs[0], product_id)
            logging.info("Selected macOS Product: {}".format(product_id))
        except KeyError:
            print("Product ID could not be found: {}".format(product_id))
            exit(1)
    else:
        print("You must provide a Product ID (or pass one of the -l or -a flags) to continue.")
        exit(1)


    # Download package to disk
    product.fetchpackages(output_dir, keyword=package)

if __name__ == "__main__":
    fetchmacos()
