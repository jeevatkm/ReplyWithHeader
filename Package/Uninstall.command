#!/bin/sh

#  Uninstall.command
#  ReplyWithHeader
#
#  Created by Jeevanandam M. on 10/9/13.
#

mh_plugin=${HOME}/Library/Mail/Bundles/ReplyWithHeader.mailbundle

echo "\n\nUninstalling ReplyWithHeader plugin"
echo "==================================="
if [ -s ${mh_plugin} ]; then
	confirm="input"
	until [[ ${confirm} =~ (y|Y) || ${confirm} =~ (N) ]]
	do
		echo "\nAre you sure want to uninstall? [y/N]"
		read confirm
	done
	
	case ${confirm} in 
		y|Y)  
			echo "Proceeding Uninstall of 'ReplyWithHeader' plugin...";
			rm -rf ${mh_plugin};
			echo "\n====================================================="
			echo "  Plugin uninstallation completed, restart Mail.app  "
			echo "====================================================="
			;;
		N)	
			echo "Aborting operation as per user choice... see ya..." ;
			exit 0
			;;
	esac
else
	echo "ReplyWithHeader plugin is not installed."
fi

