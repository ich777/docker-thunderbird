until env HOME=/etc /usr/bin/fluxbox >/dev/null 2>&1 ; do
	echo "Fluxbox crashed with exit code $?.  Respawning.." >&2
	sleep 1
done