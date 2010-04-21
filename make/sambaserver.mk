$(DEPDIR)/sambaserver: bootstrap @DEPENDS_samba@
	@PREPARE_samba@
	cd @DIR_samba@ && \
		cd source && \
		$(BUILDENV) \
		autoconf configure.in > configure && \
		./configure \
			--build=$(build) \
			--host=$(target) \
			--prefix= \
			samba_cv_struct_timespec=yes \
			samba_cv_HAVE_GETTIMEOFDAY_TZ=yes \
			--with-configdir=/etc \
			--with-privatedir=/etc/samba/private \
			--with-lockdir=/var/lock \
			--with-piddir=/var/run \
			--with-logfilebase=/var/log \
			--disable-cups \
			--with-swatdir=$(targetprefix)/swat && \
		$(MAKE) bin/make_smbcodepage CC=$(CC) && \
		$(INSTALL) -d $(targetprefix)/lib/codepages && \
		$(INSTALL) -d $(targetprefix)/var/etc/samba && \
		$(INSTALL) -d $(targetprefix)/var/etc/samba/private && \
		ln -sf /var/etc/samba/ $(targetprefix)/etc/samba && \
		ln -sf /var/etc/smb.conf $(targetprefix)/etc/smb.conf && \
		./bin/make_smbcodepage c 850 codepages/codepage_def.850 \
			$(targetprefix)/lib/codepages/codepage.850 && \
		$(MAKE) clean && \
		for i in smbd nmbd smbclient smbmount smbmnt smbpasswd; do \
			$(MAKE) bin/$$i; \
			$(INSTALL) bin/$$i $(targetprefix)/bin; \
		done
	@CLEANUP_samba@
	touch $@

#installing directories and symlinks for samba
SMB_FLASH_INSTALL = \
		$(INSTALL) -d $(flashprefix)/root/lib/codepages && \
		$(INSTALL) -d $(flashprefix)/root/var/etc/samba && \
		$(INSTALL) -d $(flashprefix)/root/var/etc/samba/private && \
		ln -sf /var/etc/samba/ $(flashprefix)/root/etc/samba && \
		ln -sf /var/etc/smb.conf $(flashprefix)/root/etc/smb.conf && \
		$(INSTALL) $(targetprefix)/lib/codepages/codepage.850 \
		$(flashprefix)/root/lib/codepages/codepage.850 

flash-smbmount: $(flashprefix)/root/bin/smbmount

$(flashprefix)/root/bin/smbmount: bootstrap sambaserver | $(flashprefix)/root
	for i in smbmount smbmnt; do \
		$(INSTALL) $(targetprefix)/bin/$$i $(flashprefix)/root/bin; \
	done
	$(SMB_FLASH_INSTALL) && \
	@FLASHROOTDIR_MODIFIED@

flash-sambaserver: $(flashprefix)/root/bin/smbd

$(flashprefix)/root/bin/smbd: bootstrap sambaserver | $(flashprefix)/root
	for i in smbd nmbd; do \
		$(INSTALL) $(targetprefix)/bin/$$i $(flashprefix)/root/bin; \
	done
	$(SMB_FLASH_INSTALL) && \
	@FLASHROOTDIR_MODIFIED@

