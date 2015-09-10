#!/bin/bash
# Script to switch configuration files and to turn
# Hyperion LEDs on and off dependent on CEC AVR
# Based off of https://github.com/Hwulex/hyperion-config-switch/
# Author: Erik Schamper
# License: The MIT License (MIT)
# http://choosealicense.com/licenses/mit/
set -u

# Check for and load config
if [ ! -e "$1" ]; then
	echo "[$(date "+%F %T")] Fatal error: Script config file not found"
	exit 2
fi

. "$1" &> /dev/null

POWER=0
INPUT=0

{
	while :
	do
		echo "[$(date "+%F %T")] Starting cec-client monitoring"

		cec-client -m -d 8 | while IFS= read event
		do
			match=$(echo "$event" | grep -c "5f:[a-zA-Z0-9:]*$")
			if [ "$match" -eq 1 ]; then
				# clean the input
				event=${event//[^s]*5f:/}

				case "$event" in
					# Power event
					"72:"*)
						state=${event:4:1}

						if [ "$state" != "$POWER" ]; then

							if [ "$state" == "0" ]; then
								# AVR turned off
								echo "[$(date "+%F %T")] AVR turned off"
								eval "$path_remote --priority 0 --color black > /dev/null 2>&1 &"
							elif [ "$state" == "1" ]; then
								# AVR turned on
								echo "[$(date "+%F %T")] AVR turned on"
								eval "$path_remote --clearall > /dev/null 2>&1 &"
							fi

							POWER=$state
						fi
						;;

					# Source change event
					"80:"*)
						target=${event:9:2}

						if [ "$target" != "$INPUT" ]; then
							echo "[$(date "+%F %T")] Input changed: $target"

							new_config="${path_config}${config_default}"

							if [ -n "`echo $src_grabber | grep $target`" ]; then
								echo "[$(date "+%F %T")] Switching to Grabber config file"
								new_config="${path_config}${config_grabber}"
							fi

							current_config=`ls -l $path_config | awk '{print $11}' | awk 1 ORS=''`

							if [ "$current_config" != "$new_config" ]; then
								# Force the config change upon Hyperion
								eval "ln -s ${new_config} ${path_config}hyperion.config.json -f"
								echo "[$(date "+%F %T")] Config file switched, restarting Hyperion"
								eval $path_reload
							else
								echo "[$(date "+%F %T")] Requested config file already in use, leaving as is"
							fi

							INPUT=$target
						fi
						;;

				esac

			fi

		done

		echo "[$(date "+%F %T")] cec-client has stopped or crashed"

		sleep 4s
	done
} >> $log 2>&1