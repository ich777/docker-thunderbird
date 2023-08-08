# Thunderbird in Docker optimized for Unraid
This container will download and install Thunderbird from the preferred branch and language.

>**UPDATE:** Please use the built in updater to update Thunderbird itself.

>**ATTENTION:** If you want to change the language, you have to delete every file in the 'thunderbird' directory except the 'profile' folder.

RESOLUTION: You can also change the resolution from the WebGUI, to do that simply click on 'Show more settings...' (on a resolution change it can occur that the screen is not filled entirely with the Thunderbird window, simply restart the container and it will be fullscreen again).

## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for Thunderbird | /thunderbird |
| THUNDERBIRD_V | Enter your preferred Thunderbird branch 'latest' or 'beta' are allowed | latest |
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
	--env 'TURBOVNC_PARAMS=-securitytypes none' \
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

## Set VNC Password:
 Please be sure to create the password first inside the container, to do that open up a console from the container (Unraid: In the Docker tab click on the container icon and on 'Console' then type in the following):

1) **su $USER**
2) **vncpasswd**
3) **ENTER YOUR PASSWORD TWO TIMES AND PRESS ENTER AND SAY NO WHEN IT ASKS FOR VIEW ACCESS**

Unraid: close the console, edit the template and create a variable with the `Key`: `TURBOVNC_PARAMS` and leave the `Value` empty, click `Add` and `Apply`.

All other platforms running Docker: create a environment variable `TURBOVNC_PARAMS` that is empty or like this:
```
    --env 'TURBOVNC_PARAMS=-securitytypes VNC'
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/
