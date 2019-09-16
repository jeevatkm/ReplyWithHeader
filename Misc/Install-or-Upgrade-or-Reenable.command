#!/bin/sh

#
#  Install-or-Upgrade-or-Reenable.command
#  ReplyWithHeader
#
#  Created by Jeevanandam M. on 10/9/13.
#
#  Revision
#  1.0	Created an initial installer script
#  1.1	Added dynamic UUID processing and few enhancements
#  1.2  Revising enable plugin logic
#  1.3  Improved OS X version print and added color support to highlight text
#  1.4  Added support for Mac OS Sierra
#  1.5  Added support for Mac OS High Sierra
#  1.6  Added support for macOS Mojave
#

mh_current_dir=`dirname "$0"`
mh_user=${USER}
mh_install_path=${HOME}/Library/Mail/Bundles
mh_plugin=${mh_install_path}/ReplyWithHeader.mailbundle
mh_plugin_plist=${mh_current_dir}/ReplyWithHeader.mailbundle/Contents/Info.plist

CC='\033[00m'
RCB='\033[01;31m'
GCB='\033[01;32m'
RC='\033[31m'
GC='\033[32m'
WC='\033[37m'
RCWHB='\033[1;31;43;5m'
BOLD='\033[1m'

echo "\n\nRWH:: Starting installation..."
echo "RWH:: Mail Plugin - ${BOLD}ReplyWithHeader${CC}"

mh_mac_osx_version_p=`sw_vers -productVersion | cut -d . -f 1,2,3`
mh_mac_osx_version=`sw_vers -productVersion | cut -d . -f 1,2`
echo "RWH:: Mac OS X version: ${mh_mac_osx_version_p}"

mh_os_ver_15grt_chk=$(echo "${mh_mac_osx_version} == 10.15" | bc)
mh_mail_app_info_plist_path="/Applications/Mail.app/Contents/Info"
if [ ${mh_os_ver_15grt_chk} -eq 1 ]; then
    mh_mail_app_info_plist_path="/System/Applications/Mail.app/Contents/Info"
fi
echo "RWH:: Mail.app Info.plist path is ${mh_mail_app_info_plist_path}"

mh_mail_version=$(defaults read "${mh_mail_app_info_plist_path}" CFBundleShortVersionString)
mh_mail_build_version=$(defaults read "${mh_mail_app_info_plist_path}" CFBundleVersion)
echo "RWH:: Mail.app ${mh_mail_version} [Build ${mh_mail_build_version}]"

if [ ! -e ${mh_install_path} ]; then
	echo "RWH:: \"${mh_install_path}\" directory not exists, creating one"
    mkdir -p "${mh_install_path}"
fi

mh_enable_plugin=1
mh_enb_success=0
if [ "${mh_user}" == "root" ] ; then
    echo "RWH:: Root users is installing plugin"
    domain=/Library/Preferences/com.apple.mail.plist
else
    echo "RWH:: user \"${mh_user}\" is installing plugin"
   domain=/Users/${mh_user}/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail.plist
fi

if [ ${mh_enable_plugin} -eq 1 ]; then
    if [ -f ${domain} ]; then
        echo "RWH:: Enabling plugin support in Mail.app"
        defaults write "${domain}" EnableBundles -bool true
        mh_enb_success=1
    fi

    if [ ${mh_enb_success} -eq 0 ]; then
        domain=/Users/${mh_user}/Library/Preferences/com.apple.mail.plist
        defaults write "${domain}" EnableBundles -bool true
    fi
    echo "RWH:: Domain is ${domain}"
fi

mh_os_ver_chk=$(echo "${mh_mac_osx_version} == 10.12 || ${mh_mac_osx_version} == 10.13 || ${mh_mac_osx_version} == 10.14 || ${mh_mac_osx_version} == 10.15" | bc)
if [ -f "${mh_mail_app_info_plist_path}.plist" ]; then
mh_mail_app_uuid=$(defaults read "${mh_mail_app_info_plist_path}" PluginCompatibilityUUID)
    if [[ ! -z "${mh_mail_app_uuid}" ]]; then
        echo "RWH:: Adding UUID ${mh_mail_app_uuid}"
echo "Supported${mh_mac_osx_version}PluginCompatibilityUUIDs"
        if [ ${mh_os_ver_chk} -eq 1 ]; then
            defaults write "${mh_plugin_plist}" "Supported${mh_mac_osx_version}PluginCompatibilityUUIDs" "(${mh_mail_app_uuid})"
        else
            defaults write "${mh_plugin_plist}" SupportedPluginCompatibilityUUIDs "(${mh_mail_app_uuid})"
        fi
    fi
fi

# for issue #66 - Version check condition updated
mh_ver_chk=$(echo "${mh_mac_osx_version} == 10.7 || ${mh_mac_osx_version} == 10.8" | bc)
if [ ${mh_ver_chk} -eq 1 ]; then
    if [ -f /System/Library/Frameworks/Message.framework/Resources/Info.plist ]; then
    mh_msg_frwk_uuid=$(defaults read /System/Library/Frameworks/Message.framework/Resources/Info.plist PluginCompatibilityUUID)
        if [[ ! -z "${mh_msg_frwk_uuid}" ]]; then
            echo "RWH:: Adding UUID ${mh_msg_frwk_uuid}"
            defaults write "${mh_plugin_plist}" SupportedPluginCompatibilityUUIDs -array-add "${mh_msg_frwk_uuid}"
        fi
    fi
fi

if [ -s ${mh_plugin} ]; then
	# mh_enable_plugin=0
	echo "\nRWH:: Plugin is already installed, lets upgrade it"
	rm -rf "${mh_plugin}"
else
	echo "\nRWH:: Installing ReplyWithHeader Mail plugin"
fi

# copy the RWH plugin
yes | cp -rf "${mh_current_dir}/ReplyWithHeader.mailbundle" "${mh_install_path}"

# for issue #48 - Resolve Permission Issue while installed by Root user
if [ "${mh_user}" == "root" ] ; then
	mh_cur_user_name="${HOME##*/}"
	echo "RWH:: Applying appropriate file permission for user \"${mh_cur_user_name}\""
	chown -R ${mh_cur_user_name} "${mh_install_path}"
	chmod -R 755 "${mh_install_path}"
fi

yes | rm -rf "${HOME}/Library/Mail/Bundles (Disabled)/ReplyWithHeader.mailbundle"

echo "RWH:: Installation complete" 

if [ ${mh_os_ver_chk} -eq 1 ]; then
    echo "\nRWH:: ${GCB}Plugin copied into \"${HOME}/Library/Mail/Bundles\"${CC}. Follow the \"Step 3\" from \"Install-Instructions-Mojave-OS-and-Above.txt\"\n\n"
else
    echo "\n========================================================="
    echo "  ${GCB}RWH Plugin successfully installed${CC}, ${RCWHB} restart Mail.app ${CC}  "
    echo "=========================================================\n\n"
fi
