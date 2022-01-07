FROM ich777/novnc-baseimage:latest_arm64

LABEL maintainer="admin@minenet.at"

RUN export TZ=Europe/Rome && \
	apt-get update && \
	apt-get -y install --no-install-recommends bzip2 libgtk-3-0 libdbus-glib-1-2 thunderbird ttf-wqy-zenhei fonts-wqy-microhei fonts-takao fonts-arphic-uming fonts-noto-cjk && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/    document.title =/c\    document.title = "Thunderbird - noVNC";' /usr/share/novnc/app/ui.js && \
	rm /usr/share/novnc/app/images/icons/*

ENV DATA_DIR=/thunderbird
ENV CUSTOM_RES_W=1024
ENV CUSTOM_RES_H=768
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="thunderbird"

RUN mkdir $DATA_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
COPY /icons/* /usr/share/novnc/app/images/icons/
COPY /conf/ /etc/.fluxbox/
RUN chmod -R 770 /opt/scripts/

EXPOSE 8080

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]