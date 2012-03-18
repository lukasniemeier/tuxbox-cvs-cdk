$(DEPDIR):
	$(INSTALL) -d $(DEPDIR)

$(DEPDIR)/bootstrap: $(CCACHE) gcc
	touch $@

$(DEPDIR)/directories:
	$(INSTALL) -d $(targetprefix)/bin
	$(INSTALL) -d $(targetprefix)/boot
	$(INSTALL) -d $(targetprefix)/dev
	$(INSTALL) -d $(targetprefix)/etc
	$(INSTALL) -d $(targetprefix)/include
	$(INSTALL) -d $(targetprefix)/mnt
	$(INSTALL) -d $(targetprefix)/lib
	$(INSTALL) -d $(targetprefix)/lib/pkgconfig
	$(INSTALL) -d $(targetprefix)/proc
	$(INSTALL) -d $(targetprefix)/root
	$(INSTALL) -d $(targetprefix)/sbin
if KERNEL26
	$(INSTALL) -d $(targetprefix)/sys
endif
	$(INSTALL) -d $(targetprefix)/tmp
	$(INSTALL) -d $(targetprefix)/var
	$(INSTALL) -d $(targetprefix)/var/etc
	ln -sf /tmp $(targetprefix)/var/run
	$(INSTALL) -d $(targetprefix)/var/tuxbox/boot
	$(INSTALL) -d $(targetprefix)$(UCODEDIR)
if ENABLE_IDE
if BOXTYPE_DREAMBOX
	$(INSTALL) -d $(targetprefix)/hdd
else
	$(INSTALL) -d $(targetprefix)/mnt/hdd1
	$(INSTALL) -d $(targetprefix)/mnt/hdd2
	$(INSTALL) -d $(targetprefix)/mnt/mmc
	ln -sf /mnt/hdd1 $(targetprefix)/hdd
endif
endif
	$(INSTALL) -d $(hostprefix)/$(target)
	$(INSTALL) -d $(hostprefix)/bin
	$(INSTALL) -d $(bootprefix)
	-rm -f $(hostprefix)/$(target)/include
	-rm -f $(hostprefix)/$(target)/lib
	-ln -sf $(targetprefix)/include $(hostprefix)/$(target)/include
	-ln -sf $(targetprefix)/lib $(hostprefix)/$(target)/lib
if BOXTYPE_DREAMBOX
	@for i in linux asm-generic asm mtd ; do \
		rm -rf $(hostprefix)/$(target)/include/$$i 2> /dev/null || /bin/true; \
		ln -sf $(buildprefix)/linux/include/$$i $(hostprefix)/$(target)/include; \
	done;
else
if !KERNEL26
	-ln -sf $(buildprefix)/linux/include/linux $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/asm $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/asm-generic $(hostprefix)/$(target)/include
	-ln -sf $(buildprefix)/linux/include/mtd $(hostprefix)/$(target)/include
endif
endif
	$(INSTALL) -d $(flashprefix)
	touch $@

# This rule script checks if all archives are present at the given address but
# does NOT download them.
#
# It takes some time so it's not useful to include it in a regular
# build

archivecheck:
	@$(buildprefix)/rules-downcheck.pl

.PHONY: archivecheck
