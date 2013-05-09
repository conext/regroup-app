#!/usr/bin/env bash

nc &> /dev/null

if [ $? -eq 127 ]; then
    echo "[!] couldn't check if app is serving."
else
    nc -z 127.0.0.1 9393 &> /dev/null
    if [ $? -eq 0 ]; then
        echo "[^] ok, server already running.."
    else
        echo "[^] app doesn't seem to be serving on port 9393."
    fi
fi

let gos=0
let nogos=0

echo -n "[-] unauthorized access check...";
correct="you're not who you think you are!"
re=$(curl -s -u photo_hut:photo_hut http://localhost:9393/group/1000/resources/file_stash | jshon -e outcome -u);
if [ "$re" == "$correct" ]; then
    echo " [ GO ]"
    let gos=gos+1
else
    echo " [ NO GO ]"
    echo "[x] got:"
    echo $re
    echo "~ but expected:"
    echo $correct 
    let nogos=nogos+1
fi

echo -n "[-] testing a proper call...";
correct="embarrasing_photos";
re=$(curl -s -u photo_hut:photo_hut http://localhost:9393/group/1000/resources/photo_hut | jshon -e 0 -e resource -e local_name -u);
if [ "$re" == "$correct" ]; then
    echo " [ GO ]"
    let gos=gos+1
else
    echo " [ NO GO ]"
    echo "[x] got:"
    echo $re
    echo "~ but expected:"
    echo $correct
    let nogos=nogos+1
fi

echo -n "[-] testing wrong credentials...";
correct="Got a reservation?";
re=$(curl -s -u photo_hut:bad_memory http://localhost:9393/group/2000/resources/photo_hut)
if [ "$re" == "$correct" ]; then
    echo " [ GO ]";
    let gos=gos+1
else
    echo " [ NO GO ]";
    echo "[x] got:"
    echo $re
    echo "~ but expected:"
    echo $correct
    let nogos=nogos+1
fi

echo -n "[-] testing PUT...";
correct='{"outcome":"ok"}';
re=$(curl -s -u photo_hut:photo_hut -X PUT http://localhost:9393/group/1000/resources/photo_hut -d '{"local_name": "T1", "uri": "T1"}')
if [ "$re" == "$correct" ]; then
    echo "[ GO ]";
    let gos=gos+1
else
    echo " [ NO GO ]";
    echo "[x] got:";
    echo $re
    echo "~ but expected:"
    echo $correct
    let nogos=nogos+1
fi

echo -n "[-] testing DELETE...";
correct='{"outcome":"obliterated"}';
re=$(curl -s -u photo_hut:photo_hut -X DELETE http://localhost:9393/group/1000/resources/photo_hut -d '{"local_name": "T1"}')
if [ "$re" == "$correct" ]; then
    echo "[ GO ]";
    let gos=gos+1
else
    echo " [ NO GO ]";
    echo "[x] got:";
    echo $re
    echo "~ but expected:"
    echo $correct
    let nogos=nogos+1
fi

echo
echo "[:] $gos GO / $nogos NO GO"

if [ $nogos -eq 0 ]; then
    echo "[*] Well, nothing seems to be completely broken."
else
    echo "[x] You broke it, it's yours now."
fi
