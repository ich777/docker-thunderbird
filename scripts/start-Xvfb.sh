until Xvfb :99 -screen scrn ${CUSTOM_RES_W}x${CUSTOM_RES_H}x16; do
	echo "Xvfb server crashed with exit code $?.  Respawning.." >&2
	sleep 1
done