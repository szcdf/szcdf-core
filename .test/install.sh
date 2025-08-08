touch /tmp/SZCDF_G__DEBUG_MODE
mv ~/.bashrc ~/.bashrc.old
mv ~/.profile ~/.profile.old
cat /szcdf_regi/szcdf-core/src/core-entries/entry-bash.sh ~/.bashrc.old >~/.bashrc
cat /szcdf_regi/szcdf-core/src/core-entries/entry-bash.sh ~/.profile.old >~/.profile
/szcdf_regi/szcdf-core/bin/szcdfi.sh