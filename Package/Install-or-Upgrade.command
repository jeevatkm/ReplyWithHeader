#!/bin/sh

#  Install-or-Upgrade.command
#  ReplyWithHeader
#
#  Created by Jeevanandam M. on 10/9/13.
#

mh_install_path=${HOME}/Library/Mail/Bundles
mh_plugin=${mh_install_path}/ReplyWithHeader.mailbundle

OS_VERSION=`sw_vers -productVersion | cut -d . -f 1,2`
if [ $OS_VERSION == '10.8' ]; then
    PLUGIN_COMPAT=6
elif [ $OS_VERSION == '10.7' ]; then
    PLUGIN_COMPAT=5
fi

echo "\n\nMac OS X version: ${OS_VERSION}"
echo "Mail Plugin: ReplyWithHeader"

if [ ! -e ${mh_install_path} ]; then
    echo "\nCreating ${mh_install_path}"
    mkdir -p ${mh_install_path}
fi

if [ -s ${mh_plugin} ]; then
	echo "\nPlugin is already install, let's upgrade it"
	rm -rf ${mh_plugin}
else
	echo "\nInstalling ReplyWithHeader plugin"
fi

CURRENT_DIR=`dirname "$0"`
cp -r "${CURRENT_DIR}/ReplyWithHeader.mailbundle" ${mh_install_path}

chk_res=$(defaults read com.apple.mail EnableBundles)
if [[ ${chk_res} -ne "1" ]]; then
	echo "Plugin support not enabled in Mail.app, let's enable it"
	defaults write com.apple.mail EnableBundles -bool true
	defaults write com.apple.mail BundleCompatibilityVersion $PLUGIN_COMPAT
	echo "Plugin support is now enabled in Mail.app"
else
	echo "Plugin support already enabled in Mail.app, no action required."
fi

echo "\n==================================================="
echo "  Plugin installation completed, restart Mail.app  "
echo "==================================================="
