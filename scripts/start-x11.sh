until x11vnc -display :99 -rfbport 5900 -shared -forever ${X11VNC_PARAMS}; do
    echo "x11vnc server crashed with exit code $?.  Respawning.." >&2
    sleep 1
done