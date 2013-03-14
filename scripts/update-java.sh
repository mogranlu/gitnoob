#!/bin/bash
#################################################
# Author: Morten Granlund
#
# Prerequisites:
# ---------------
# 1) Download latest versino of jre-7uxy-linux-x64.tar.gz
# 2) Unpack (tar -xzf) the compressed tar ball
# 3) 
declare -r user="morten"
declare -r downloadDir="/home/${user}/Downloads/"
declare -r jvmLink="/usr/lib/jvm/jre1.7.0"
declare -r jvmDir="/opt/java"
declare -r mozillaPluginDir="/home/$user/.mozilla/plugins"

#-------
#
#-------
function failIfNotRoot() {
	if [ "$(id -u)" != "0" ]; then
   		echo "This script must be run as root" 1>&2
   		exit 1
	fi
}

#-----
#
#-----
function logDebug() {
	echo "DEBUG: $1"
}

#-------------------------------------------------------------
# Searches and print to standard out the latest version of 
# Oracle Java JRE found in the folder: ${downloadDir}
#-------------------------------------------------------------
function findLatestJreTarBallInDownloadsFolder() {
	declare -r file_regexp="jre-7u[0-9]\{2\}-linux-.*\.tar\.gz"

	# Searching for the latest version of Oracle Java JRE in the folder: ${downloadDir}...
	declare -r latestJRE=$(ls -l ${downloadDir} | grep $file_regexp | awk '{ print $NF }' | sort -u | tail -1)

	echo $latestJRE	
}

function linkToJavaFromMozillaPluginDir() {

	declare -r javaplugin=$1

	if [[ ! -d "$mozillaPluginDir" ]];
	then
		mkdir --parent $mozillaPluginDir
	fi

	chown $user:$user -R $mozillaPluginDir
	
	# TODO - check for old link, delete old link, and make sure new one works!
	ln --symbolic --force $javaplugin $mozillaPluginDir/libnpjp2.so
}

failIfNotRoot

logDebug "Searching for Oracle Java JRE installation files (compressed tar balls) in folder ${downloadDir}..."
latestJreTarBall=$(findLatestJreTarBallInDownloadsFolder)
logDebug "Found the following Oracle Java JRE to be the latest (and greatest): ${latestJreTarBall}"	

declare -r rootDirInTarBall=$(tar -tzf $downloadDir/$latestJreTarBall | sed 's/\/.*//' | head -1)
logDebug "Installing the Java Runetime environment in the following directory: ${jvmDir}..."
tar -xzf $downloadDir/$latestJreTarBall --directory $jvmDir
logDebug "Changing owner (and group) on the files to: $user"

chown $user:$user -R $jvmDir/$rootDirInTarBall/
if [ -L $jvmLink ]; then
	rm $jvmLink
fi
ln --symbolic --verbose $jvmDir/$rootDirInTarBall/ $jvmLink
chown $user:$user $jvmLink

logDebug "Installing the java plugin in the mozilla plugin directory: ${mozillaPluginDir}..."
declare -r java_plugin=$(find -L $jvmLink -type f -name "libnpjp2.so" -print)
linkToJavaFromMozillaPluginDir $java_plugin

logDebug "DONE!"


