#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo FATAL ERROR EXIT CODE $? AT $0:$LINENO' ERR

./download-teddy
./InfiniTAM Teddy/calib.txt 'Teddy/Frames/%04i.ppm' 'Teddy/Frames/%04i.pgm'
