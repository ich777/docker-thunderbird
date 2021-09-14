# Thunderbird in Docker optimized for Unraid
This container will download and install Thunderbird in the preferred version and language.

>**UPDATE:** The container will check on every restart if there is a newer version available.

>**ATTENTION:** If you want to change the language, you have to delete every file in the 'thunderbird' directory except the 'profile' folder.

RESOLUTION: You can also change the resolution from the WebGUI, to do that simply click on 'Show more settings...' (on a resolution change it can occour that the screen is not filled entirely with the Thunderbird window, simply restart the container and it will be fullscreen again).

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for Thunderbird | /thunderbird |
| THUNDERBIRD_V | Enter your preferred Thunderbird version or 'latest' to install the latest version | latest |
| THUNDERBIRD_LANG | Enter your preferred Thunderbird language you can get a full list here: https://archive.mozilla.org/pub/thunderbird/releases/latest/README.txt | en-US |
| CUSTOM_RES_W | Enter your preferred screen width | 1280 |
| CUSTOM_RES_H | Enter your preferred screen height | 768 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value | 000 |
| DATA_PERM | Data permissions for /thunderbird folder | 770 |

## Run example
```
docker run --name Thunderbird -d \
	-p 8080:8080 \
	--env 'THUNDERBIRD_V=latest' \
	--env 'THUNDERBIRD_LANG=en-US' \
	--env 'CUSTOM_RES_W=1280' \
	--env 'CUSTOM_RES_H=768' \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=000' \
	--env 'DATA_PERM=770' \
	--volume /mnt/cache/appdata/thunderbird:/thunderbird \
	ich777/thunderbird
```
### Webgui address: http://[SERVERIP]:[PORT]/vnc.html?autoconnect=true

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/
