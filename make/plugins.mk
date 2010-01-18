# tuxbox/plugins

$(appsdir)/tuxbox/plugins/config.status: bootstrap libfreetype libcurl libz libsigc libpng libjpeg $(targetprefix)/lib/pkgconfig/tuxbox.pc $(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc $(targetprefix)/lib/pkgconfig/tuxbox-tuxtxt.pc
	cd $(appsdir)/tuxbox/plugins && $(CONFIGURE)

plugins: neutrino-plugins enigma-plugins @FX2PLUGINS@

neutrino-plugins: $(targetprefix)/include/tuxbox/plugin.h tuxmail tuxtxt tuxcom tuxcal vncviewer dvbsub shellexec tuxwetter sysinfo clock

fx2-plugins: $(appsdir)/tuxbox/plugins/config.status @DEPENDS_tuxfrodo@
	$(MAKE) -C $(appsdir)/tuxbox/plugins/fx2 all install
if BOXTYPE_DBOX2
	@PREPARE_tuxfrodo@
	tar -C $(targetprefix)/lib/tuxbox/plugins/c64emu/ -xjvf @DIR_tuxfrodo@/hdd/c64emu/roms.tar.bz2
	@CLEANUP_tuxfrodo@
endif

enigma-plugins: @LIBGETTEXT@ $(appsdir)/tuxbox/plugins/config.status $(targetprefix)/include/tuxbox/plugin.h
	$(MAKE) -C $(appsdir)/tuxbox/plugins/enigma all install

$(targetprefix)/include/tuxbox/plugin.h \
$(targetprefix)/lib/pkgconfig/tuxbox-plugins.pc: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/include all install
	cp $(appsdir)/tuxbox/plugins/tuxbox-plugins.pc $(targetprefix)/lib/pkgconfig/tuxbox-plugins.pc

tuxmail: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxmail all install

flash-tuxmail: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxmail all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

pluginx: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/pluginx all install

flash-pluginx: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/pluginx all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

tuxtxt: $(appsdir)/tuxbox/plugins/config.status $(targetprefix)/include/tuxbox/plugin.h
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxtxt all install

flash-tuxtxt: $(appsdir)/tuxbox/plugins/config.status tuxtxt | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxtxt install  prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

tuxcom: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxcom all install

flash-tuxcom: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxcom all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

tuxcal: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxcal all install

flash-tuxcal: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxcal all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

tuxclock: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxclock all install

flash-tuxclock: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxclock all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

vncviewer: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/vncviewer all install

flash-vncviewer: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/vncviewer all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

pip: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/pip all install

flash-pip: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/pip all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

mosaic: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/mosaic all install

flash-mosaic: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/mosaic all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

shellexec: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/shellexec all install

flash-shellexec: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/shellexec all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

tuxwetter: libungif $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxwetter all install

flash-tuxwetter: libungif $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/tuxwetter all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

sysinfo: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/sysinfo all install

flash-sysinfo: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/sysinfo all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

clock: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/clock all install

flash-clock: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/clock all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

dvbsub: $(appsdir)/tuxbox/plugins/config.status
	$(MAKE) -C $(appsdir)/tuxbox/plugins/dvbsub all install

flash-dvbsub: $(appsdir)/tuxbox/plugins/config.status | $(flashprefix)/root
	$(MAKE) -C $(appsdir)/tuxbox/plugins/dvbsub all install prefix=$(flashprefix)/root
	@FLASHROOTDIR_MODIFIED@

# $(appsdir)/tuxbox/plugins/fx2/*/Makefile.am are silly and should be
# rewritten.  In the meantime, use this kludge.
flash-fx2-plugins: fx2-plugins | $(flashprefix)/root
	$(INSTALL) -d $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -m 755 $(appsdir)/tuxbox/plugins/fx2/[c-z]*/.libs/*.so $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -m 644 $(appsdir)/tuxbox/plugins/fx2/[c-z]*/*.cfg $(flashprefix)/root/lib/tuxbox/plugins
	$(INSTALL) -d $(flashprefix)/root/share/tuxbox/sokoban 
	$(INSTALL) -m 0644 $(appsdir)/tuxbox/plugins/fx2/sokoban/*.xsb $(flashprefix)/root/share/tuxbox/sokoban
	if [ -e $(flashprefix)/root/lib/libfx2.so ]; then \
		if [ -e $(flashprefix)/root/lib/tuxbox/plugins/ ]; then \
			rm -f $(flashprefix)/root/lib/tuxbox/plugins/libfx2.so ; \
			ln -s /lib/libfx2.so $(flashprefix)/root/lib/tuxbox/plugins/libfx2.so; \
		fi ; \
	fi
	@FLASHROOTDIR_MODIFIED@
