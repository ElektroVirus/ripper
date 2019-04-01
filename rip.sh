#!/bin/bash
MUSICDIR=${1:-${HOME}/music}
CMDLINE="docker run -ti --rm --privileged -v /dev/sr0:/dev/sr0 -v /dev/cdrom:/dev/cdrom -v ${HOME}/.config/whipper:/home/worker/.config/whipper -v ${MUSICDIR}:/output wappuradio/ripper"
mkdir -p ${MUSICDIR}
if [ "$(docker images -q wappuradio/ripper)" == "" ]; then
  echo "Building docker image..."
  docker build -t wappuradio/ripper github.com/wappuradio/ripper
fi
if [ ! -f ${HOME}/.config/whipper/whipper.conf ]; then
  echo "Running first time configuration. Please insert a known disc and press enter to continue or configure manually..."
  read
  mkdir -p ${HOME}/.config/whipper
  $CMDLINE drive analyze 
  $CMDLINE offset find
fi
$CMDLINE cd rip --disc-template="%A - %d - %y/%A - %d" --track-template="%A - %d - %y/%t - %a - %n" -L eac -p
