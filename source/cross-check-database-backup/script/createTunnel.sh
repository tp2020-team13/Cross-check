createTunnel() {
    /usr/bin/ssh -f -N -L 5433:crosscheck.fiit.stuba.sk:5433 -L 19922:crosscheck.fiit.stuba.sk:22 studenti@crosscheck.fiit.stuba.sk
    if [[ $? -eq 0 ]]; then
        echo Tunnel to hostb created successfully
    else
        echo An error occurred creating a tunnel to hostb RC was $?
    fi
}
## Run the 'ls' command remotely.  If it returns non-zero, then create a new connection
/usr/bin/ssh -p 19922 studenti@localhost ls
if [[ $? -ne 0 ]]; then
    echo Creating new tunnel connection
    createTunnel
fi
