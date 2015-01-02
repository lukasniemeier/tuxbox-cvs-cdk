echo CLEANING
make -s clean > ../clean.log 2>&1
echo CONFIGURING
./configure --with-cvsdir=/home/lukas/tuxbox-cvs --prefix=/home/lukas/dbox2 --with-customizationsdir=/home/lukas/dbox2-files/custom --with-ucodesdir=/home/lukas/dbox2-files/ucodes --enable-maintainer-mode --disable-drive-gui --disable-gui-mount --disable-audioplayer --disable-pictureviewer --disable-movieplayer --enable-lirc --disable-tuxmail --enable-aformat --enable-ccache > ../configure.log 2>&1
echo BUILDING
make flash-neutrino-jffs2-2x > ../build.log 2>&1
automake --add-missing
make flash-lircd flash-neutrino-jffs2-2x >> ../build.log 2>&1
nawk 'c-->0;$0~s{if(b)for(c=b+1;c>1;c--)print r[(NR-c+1)%b];print;c=a}b{r[NR%b]=$0}' b=10 a=0 s="make[1]: *** [all] Error 2" ../build.log
nawk 'c-->0;$0~s{if(b)for(c=b+1;c>1;c--)print r[(NR-c+1)%b];print;c=a}b{r[NR%b]=$0}' b=1 a=0 s="no system" ../build.log
