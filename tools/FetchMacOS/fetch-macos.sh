#!/bin/sh -e

SWUPDATE_AGENT="Software%20Update (unknown version) CFNetwork/807.0.1 Darwin/16.0.0 (x86_64)"
OSINSTALL_AGENT="osinstallersetupplaind (unknown version) CFNetwork/720.5.7 Darwin/14.5.0 (x86_64)"

CUSTOMER_SEED_SERVICE="https://swscan.apple.com/content/catalogs/others/index-10.15customerseed-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
DEVELOPER_SEED_SERVICE="https://swscan.apple.com/content/catalogs/others/index-10.15seed-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
PUBLIC_SEED_SERVICE="https://swscan.apple.com/content/catalogs/others/index-10.15beta-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
PUBLIC_RELEASE_SERVICE="https://swscan.apple.com/content/catalogs/others/index-10.15-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
PUBLIC_RELEASE_14_SERVICE="https://swscan.apple.com/content/catalogs/others/index-10.14-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"
PUBLIC_RELEASE_13_SERVICE="https://swscan.apple.com/content/catalogs/others/index-10.13-10.12-10.11-10.10-10.9-mountainlion-lion-snowleopard-leopard.merged-1.sucatalog"

OUTPUT_DIR="$(dirname ${0})/BaseSystem"

while getopts "o:c:p:l" OPT; do
  case "${OPT}" in
    o) OUTPUT_DIR="${OPTARG}";;
    c) CATALOG_ID="${OPTARG}";;
    p) PRODUCT_ID="${OPTARG}";;
  esac
done

case ${CATALOG_ID} in
  CustomerSeed) SOFTWARE_SERVICE_URL="${CUSTOMER_SEED_SERVICE}";;
  DeveloperSeed) SOFTWARE_SERVICE_URL="${DEVELOPER_SEED_SERVICE}";;
  PublicSeed) SOFTWARE_SERVICE_URL="${PUBLIC_SEED_SERVICE}";;
  PublicRelease) SOFTWARE_SERVICE_URL="${PUBLIC_RELEASE_SERVICE}";;
  PublicRelease14) SOFTWARE_SERVICE_URL="${PUBLIC_RELEASE_14_SERVICE}";;
  PublicRelease13) SOFTWARE_SERVICE_URL="${PUBLIC_RELEASE_13_SERVICE}";;
  *) SOFTWARE_SERVICE_URL="${PUBLIC_RELEASE_SERVICE}";;
esac

TMP_CATALOG_FILE=`mktemp`
curl -sSL -o "${TMP_CATALOG_FILE}" -A "${SWUPDATE_AGENT}" "${SOFTWARE_SERVICE_URL}"

[ -z "${PRODUCT_ID}" ] && PRODUCT_ID=`xmlstarlet sel --net -t -m "/plist/dict/key[.='Products']/following-sibling::dict[1]/key/following-sibling::dict[1]/key[.='ExtendedMetaInfo']/following-sibling::dict[1]/key[.='InstallAssistantPackageIdentifiers']/following-sibling::dict[1]/key[.='OSInstall']/following-sibling::string[1][text()='com.apple.mpkg.OSInstall']" -n -v "parent::dict[1]/parent::dict[1]/parent::dict[1]/preceding-sibling::key[1]" "${TMP_CATALOG_FILE}" | tail -n1`

mkdir -p ${OUTPUT_DIR}
for i in `xmlstarlet sel --net -t -m "/plist/dict/key[.='Products']/following-sibling::dict[1]/key[.='${PRODUCT_ID}']/following-sibling::dict[1]/key[.='Packages']/following-sibling::array[1]" -n -v "dict/key[.='URL']/following-sibling::string[1]" "${TMP_CATALOG_FILE}" | grep BaseSystem`; do
  curl -SL -o "${OUTPUT_DIR}/$(basename ${i})" -A "${OSINSTALL_AGENT}" "${i}"
done
rm "${TMP_CATALOG_FILE}"
