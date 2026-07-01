#!/bin/sh

pkill rofi || true && /usr/bin/rofi -show drun -modi drun,filebrowser,run,window
