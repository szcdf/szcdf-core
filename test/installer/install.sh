#!/usr/bin/env bash
touch /tmp/SZCDF_G__DEBUG_MODE
cp ~/.bashrc ~/.bashrc.old
cp ~/.profile ~/.profile.old
/szcdf-core/bin/szcdfi.sh