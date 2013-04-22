#!/usr/bin/env bash

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

echo
echo "[:] $gos GO / $nogos NO GO"

if [ $nogos -eq 0 ]; then
    echo "[*] Well, nothing seems to be completely broken."
else
    echo "[x] You broke it, it's yours now."
fi
