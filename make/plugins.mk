# tuxbox/plugins

$(appsdir)/tuxbox/plugins/config.status: bootstrap libfreetype libcurl libz libsigc libpng libjpeg $(targetprefix)/lib/pkgconfig/tuxbox.pc $(targetprefix)/lib/pkgconfig/tuxbox-xmltree.pc $(targetprefix)/lib/pkgconfig/tuxbox-tuxtxt.pc
	cd $(appsdir)/tuxbox/plugins && $(CONFIGURE)

plugins: neutrino-plugins enigma-plugins

neutrino-plugins: $(targetprefix)/include/tuxbox/plugin.h tuxmail tuxtxt tuxcom tuxcal vncviewer dvbsub shellexec tuxwetter sysinfo clock

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
