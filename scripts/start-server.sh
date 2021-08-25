#!/bin/bash
export DISPLAY=:99
export XAUTHORITY=${DATA_DIR}/.Xauthority

CUR_V="$(${DATA_DIR}/thunderbird --version 2>/dev/null | cut -d ' ' -f3)"
if [ "${THUNDERBIRD_V}" == "latest" ]; then
	LAT_V="$(wget -qO- https://github.com/ich777/versions/raw/master/Thunderbird | grep LATEST | cut -d '=' -f2)"
	sleep 2
	THUNDERBIRD_V="${LAT_V}"
	if [ -z "$LAT_V" ]; then
		if [ ! -z "$CUR_V" ]; then
			echo "---Can't get latest version of Thunderbird falling back to v$CUR_V---"
			LAT_V="$CUR_V"
		else
			echo "---Something went wrong, can't get latest version of Thunderbird, putting container into sleep mode---"
			sleep infinity
		fi
	fi
fi

rm -R ${DATA_DIR}/Thunderbird-*.tar.bz2

echo "---Version Check---"
if [ -z "$CUR_V" ]; then
	echo "---Thunderbird not installed, installing---"
	cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/Thunderbird-$LAT_V-$THUNDERBIRD_LANG.tar.bz2 "https://archive.mozilla.org/pub/thunderbird/releases/${THUNDERBIRD_V}/linux-x86_64/${THUNDERBIRD_LANG}/thunderbird-${THUNDERBIRD_V}.tar.bz2" ; then
		echo "---Sucessfully downloaded Thunderbird---"
	else
		echo "---Something went wrong, can't download Thunderbird, putting container in sleep mode---"
		sleep infinity
	fi
	tar -C ${DATA_DIR} --strip-components=1 -xf ${DATA_DIR}/Thunderbird-$LAT_V-$THUNDERBIRD_LANG.tar.bz2
	rm -R ${DATA_DIR}/Thunderbird-$LAT_V-$THUNDERBIRD_LANG.tar.bz2
elif [ "$CUR_V" != "$LAT_V" ]; then
	echo "---Version missmatch, installed v$CUR_V, downloading and installing latest v$LAT_V...---"
    cd ${DATA_DIR}
	find . -maxdepth 1 ! -name profile -exec rm -rf {} \; 2>/dev/null
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/Thunderbird-$LAT_V-$THUNDERBIRD_LANG.tar.bz2 "https://archive.mozilla.org/pub/thunderbird/releases/${THUNDERBIRD_V}/linux-x86_64/${THUNDERBIRD_LANG}/thunderbird-${THUNDERBIRD_V}.tar.bz2" ; then
		echo "---Sucessfully downloaded Thunderbird---"
	else
		echo "---Something went wrong, can't download Thunderbird, putting container in sleep mode---"
		sleep infinity
	fi
	tar -C ${DATA_DIR} --strip-components=1 -xf ${DATA_DIR}/Thunderbird-$LAT_V-$THUNDERBIRD_LANG.tar.bz2
	rm -R ${DATA_DIR}/Thunderbird-$LAT_V-$THUNDERBIRD_LANG.tar.bz2
elif [ "$CUR_V" == "$LAT_V" ]; then
	echo "---Thunderbird v$CUR_V up-to-date---"
fi

echo "---Preparing Server---"
if [ ! -d ${DATA_DIR}/profile ]; then
	mkdir -p ${DATA_DIR}/profile
fi
echo "---Resolution check---"
if [ -z "${CUSTOM_RES_W} ]; then
	CUSTOM_RES_W=1024
fi
if [ -z "${CUSTOM_RES_H} ]; then
	CUSTOM_RES_H=768
fi

if [ "${CUSTOM_RES_W}" -le 1023 ]; then
	echo "---Width to low must be a minimal of 1024 pixels, correcting to 1024...---"
    CUSTOM_RES_W=1024
fi
if [ "${CUSTOM_RES_H}" -le 767 ]; then
	echo "---Height to low must be a minimal of 768 pixels, correcting to 768...---"
    CUSTOM_RES_H=768
fi
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \;
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \;
echo "---Checking for old display lock files---"
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
screen -d -m env HOME=/etc /usr/bin/fluxbox
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting Thunderbird---"
cd ${DATA_DIR}
${DATA_DIR}/thunderbird --display=:99 --profile ${DATA_DIR}/profile --P ${USER} --setDefaultMail ${EXTRA_PARAMETERS}