#!/bin/sh

#  create-dmg.sh
#  ReplyWithHeader
#
#  Created by Jeevanandam M. on 10/9/13.
#

MH_PACKAGE_TEMP_DIR=/tmp/MailHeader
MH_SOURCE_DIR=${MH_PACKAGE_TEMP_DIR}/package
MH_DMG_VOLUME_NAME=${PRODUCT_NAME}
MH_BUNDLE_FILENAME=${WRAPPER_NAME}
MH_DMG_SIZE=10960
MH_DMG_TEMP_NAME=mh-temp.dmg
MH_DMG_BG_PIC_NAME=dmg-background.png
MH_BUILD_VERSION=$(defaults read ${BUILT_PRODUCTS_DIR}/${MH_BUNDLE_FILENAME}/Contents/Info CFBundleVersion)

apply_dmg_permission() 
{
	echo -e "Applies permissions to mounted volume (${MH_DMG_VOLUME_NAME})"
	chmod -Rf go-w /Volumes/"${MH_DMG_VOLUME_NAME}"
	sync
	sync
}

echo -e "====== Creating DMG Installer ======"
echo -e "Product: ${PRODUCT_NAME}  \tVersion: ${MH_BUILD_VERSION}"
echo -e "==========================="

echo -e "Preparing required directories"
mkdir -p ${MH_PACKAGE_TEMP_DIR}
mkdir -p ${MH_SOURCE_DIR}
mkdir -p ${MH_SOURCE_DIR}/.HiddenFiles

# preparing required files
cp ${SRCROOT}/Package/Install-or-Upgrade.command ${MH_SOURCE_DIR}
cp -r ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME} ${MH_SOURCE_DIR}/.HiddenFiles

echo -e "Cleaning up files"
find ${MH_SOURCE_DIR} -name '*.DS_Store' -type f -delete

echo -e "Creating Read/Write DMG"
hdiutil create -srcfolder "${MH_SOURCE_DIR}" -volname "${MH_DMG_VOLUME_NAME}" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size ${MH_DMG_SIZE}k "${MH_PACKAGE_TEMP_DIR}/${MH_DMG_TEMP_NAME}"

echo -e "Mounting ${MH_DMG_TEMP_NAME} dmg file"
device=$(hdiutil attach -readwrite -noverify -noautoopen "${MH_PACKAGE_TEMP_DIR}/${MH_DMG_TEMP_NAME}" | egrep '^/dev/' | sed 1q | awk '{print $1}')

sleep 10

echo -e "Preparing mounted volume (${MH_DMG_VOLUME_NAME}) for distribution"
osascript -e '
tell application "Finder"
tell disk "'${MH_DMG_VOLUME_NAME}'"
open
set current view of container window to icon view
set toolbar visible of container window to false
set statusbar visible of container window to false
set the bounds of container window to {400, 100, 700, 230}
set theViewOptions to the icon view options of container window
set arrangement of theViewOptions to not arranged
set icon size of theViewOptions to 72
update without registering applications
delay 5
end tell
end tell
'

apply_dmg_permission || true

echo -e "Detaching volume ${MH_DMG_VOLUME_NAME}"
hdiutil detach "${device}"

sleep 10

echo -e "Compressing volume ${MH_DMG_VOLUME_NAME} for final distribution"
hdiutil convert "${MH_PACKAGE_TEMP_DIR}/${MH_DMG_TEMP_NAME}" -format UDZO -imagekey zlib-level=9 -o "${MH_PACKAGE_TEMP_DIR}/${MH_DMG_VOLUME_NAME}-${MH_BUILD_VERSION}.dmg"

echo -e "Copying final DMG into Downloads folder"
cp "${MH_PACKAGE_TEMP_DIR}/${MH_DMG_VOLUME_NAME}-${MH_BUILD_VERSION}.dmg" ~/Downloads/

echo -e "Cleaning up at the end"
rm -rf "${MH_PACKAGE_TEMP_DIR}"
