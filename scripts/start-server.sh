#!/bin/bash
export DISPLAY=:99
export XAUTHORITY=${DATA_DIR}/.Xauthority

CUR_V="$(${DATA_DIR}/thunderbird --version 2>/dev/null | cut -d ' ' -f3)"
if [ "${THUNDERBIRD_V}" == "latest" ]; then
  if [ ! -f ${DATA_DIR}/latest_branch ]; then
    LATEST_DL=true
  fi
elif [ "${THUNDERBIRD_V}" == "beta" ]; then
  if [ ! -f ${DATA_DIR}/beta_branch ]; then
    BETA_DL=true
  fi
else
  echo "---The Thunderbird version can only be \"latest\" or \"beta\", putting container in sleep mode---"
  sleep infinity
fi

rm -R ${DATA_DIR}/Thunderbird-*.tar.bz2 2>/dev/null

download_thunderbird() {
if [ "${LATEST_DL}" == "true" ]; then
  echo "---Thunderbird not installed, installing---"
  cd ${DATA_DIR}
  find . -maxdepth 1 ! -name profile ! -name .vnc -exec rm -rf {} \; 2>/dev/null
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/Thunderbird-$THUNDERBIRD_V-$THUNDERBIRD_LANG.tar.bz2 "https://download.mozilla.org/?product=thunderbird-latest&os=linux64&lang=$THUNDERBIRD_LANG" ; then
    echo "---Sucessfully downloaded Thunderbird \"latest\"---"
  else
    echo "---Something went wrong, can't download Thunderbird \"latest\", putting container in sleep mode---"
    sleep infinity
  fi
  tar -C ${DATA_DIR} --strip-components=1 -xf ${DATA_DIR}/Thunderbird-$THUNDERBIRD_V-$THUNDERBIRD_LANG.tar.bz2
  rm -R ${DATA_DIR}/Thunderbird-$THUNDERBIRD_V-$THUNDERBIRD_LANG.tar.bz2
  touch ${DATA_DIR}/latest_branch
elif [ "${BETA_DL}" == "true" ]; then
  echo "---Thunderbird not installed, installing---"
  cd ${DATA_DIR}
  find . -maxdepth 1 ! -name profile ! -name .vnc -exec rm -rf {} \; 2>/dev/null
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/Thunderbird-$THUNDERBIRD_V-$THUNDERBIRD_LANG.tar.bz2 "https://download.mozilla.org/?product=thunderbird-beta-latest-SSL&os=linux64&lang=$THUNDERBIRD_LANG" ; then
    echo "---Sucessfully downloaded Thunderbird \"latest\"---"
  else
    echo "---Something went wrong, can't download Thunderbird \"latest\", putting container in sleep mode---"
    sleep infinity
  fi
  tar -C ${DATA_DIR} --strip-components=1 -xf ${DATA_DIR}/Thunderbird-$THUNDERBIRD_V-$THUNDERBIRD_LANG.tar.bz2
  rm -R ${DATA_DIR}/Thunderbird-$THUNDERBIRD_V-$THUNDERBIRD_LANG.tar.bz2
  touch ${DATA_DIR}/beta_branch
fi
}

if [ -z "$CUR_V" ]; then
  download_thunderbird
elif [ "$LATEST_DL" == "true" ]; then
  download_thunderbird
elif [ "$BETA_DL" == "true" ]; then
  download_thunderbird
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
chmod -R ${DATA_PERM} ${DATA_DIR}
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
/opt/scripts/start-fluxbox.sh &
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting Thunderbird---"
cd ${DATA_DIR}
${DATA_DIR}/thunderbird --display=:99 --profile ${DATA_DIR}/profile --P ${USER} --setDefaultMail ${EXTRA_PARAMETERS}