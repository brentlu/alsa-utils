#!/bin/bash

#DBG="gdb --args "
#DBG="strace"
#DBG="valgrind --leak-check=full"
ARGS=
CFGFILE="/tmp/alsaloop.test.cfg"

test1() {
  echo "TEST1"
  $DBG ./alsaloop -C hw:1,0 -P plughw:0,0 \
    --tlatency 50000 \
    --mixer "name='Master Playback Volume'@name='Master Playback Volume'" \
    --mixer "name='Master Playback Switch'@name='Master Playback Switch'" \
    --mixer "name='PCM Playback Volume'" \
    --ossmixer "Master@VOLUME" \
    --ossmixer "PCM@PCM" \
    $ARGS
}

test2() {
  echo "TEST2"
cat > $CFGFILE <<EOF
# first job
-C hw:1,0,0 -P hw:0,0,0 --tlatency 50000 --thread 1 \
    --mixer "name='Master Playback Volume'@name='Master Playback Volume'" \
    --mixer "name='Master Playback Switch'@name='Master Playback Switch'" \
    --mixer "name='PCM Playback Volume'"
# next line - second job
-C hw:1,0,1 -P hw:0,1,0 --tlatency 50000 --thread 2
EOF
  $DBG ./alsaloop -d --config $CFGFILE $ARGS
}

test3() {
  echo "TEST3"
cat > $CFGFILE <<EOF
-C hw:1,0,0 -P plug:dmix:0 --tlatency 50000 --thread 0 \
    --mixer "name='Master Playback Volume'@name='Master Playback Volume'" \
    --mixer "name='Master Playback Switch'@name='Master Playback Switch'" \
    --mixer "name='PCM Playback Volume'" \
    --ossmixer "name=Master@VOLUME"
-C hw:1,0,1 -P plug:dmix:0 --tlatency 50000 --thread 1
-C hw:1,0,2 -P plug:dmix:0 --tlatency 50000 --thread 2
-C hw:1,0,3 -P plug:dmix:0 --tlatency 50000 --thread 3
-C hw:1,0,4 -P plug:dmix:0 --tlatency 50000 --thread 4
-C hw:1,0,5 -P plug:dmix:0 --tlatency 50000 --thread 5
-C hw:1,0,6 -P plug:dmix:0 --tlatency 50000 --thread 6
-C hw:1,0,7 -P plug:dmix:0 --tlatency 50000 --thread 7
EOF
  LD_PRELOAD="/home/perex/alsa/alsa-lib/src/.libs/libasound.so" \
  $DBG ./alsaloop --config $CFGFILE $ARGS
}

test4() {
  echo "TEST4"
  $DBG ./alsaloop -C hw:1,0 -P plughw:0,0 -a off -r 11025 \
    --tlatency 50000 \
    --mixer "name='Master Playback Volume'@name='Master Playback Volume'" \
    --mixer "name='Master Playback Switch'@name='Master Playback Switch'" \
    --mixer "name='PCM Playback Volume'" \
    $ARGS
}

test5() {
  echo "TEST5"
cat > $CFGFILE <<EOF
-C hw:1,0,0 -P plughw:0,0 --tlatency 50000 --thread 1 \
    --mixer "name='Master Playback Volume'@name='Master Playback Volume'" \
    --mixer "name='Master Playback Switch'@name='Master Playback Switch'" \
    --mixer "name='PCM Playback Volume'" \
    --ossmixer "name=Master@VOLUME"
-C hw:1,0,1 -P plughw:0,1 --tlatency 50000 --thread 2
EOF
  $DBG ./alsaloop --config $CFGFILE $ARGS
}

case "$1" in
test1) shift; ARGS="$@"; test1 ;;
test2) shift; ARGS="$@"; test2 ;;
test3) shift; ARGS="$@"; test3 ;;
test4) shift; ARGS="$@"; test4 ;;
test5) shift; ARGS="$@"; test5 ;;
*) ARGS="$@"; test1 ;;
esac