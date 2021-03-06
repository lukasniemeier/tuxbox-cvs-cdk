
if ENABLE_MMC
KERNEL_M4 += -Dmmc
endif
if BOXMODEL_IP250
KERNEL_M4 += -Dwlan
endif
if BOXMODEL_IP350
KERNEL_M4 += -Dwlan
KERNEL_M4 += -Dusb
endif

ipbox_flash_imgs_neutrino \
ipbox_flash_imgs_enigma: \
ipbox_flash_imgs_%: \
$(flashprefix)/flash_img_low_%.img \
$(flashprefix)/flash_img_high_%.img \
$(flashprefix)/flash_img_noboot_%.img \
$(flashprefix)/flash_img_kernel_root_%.img


# Tools

$(hostprefix)/bin/appendbin:
	$(MAKE) -C $(hostappsdir)/appendbin install INSTALLDIR=$(hostprefix)/bin

$(hostprefix)/bin/convbmp:
	$(MAKE) -C $(hostappsdir)/convbmp install INSTALLDIR=$(hostprefix)/bin

$(hostprefix)/bin/mkdnimg:
	$(MAKE) -C $(hostappsdir)/mkdnimg install INSTALLDIR=$(hostprefix)/bin

$(hostprefix)/bin/mkwelcomeimg:
	$(MAKE) -C $(hostappsdir)/mkwelcomeimg install INSTALLDIR=$(hostprefix)/bin


# U-Boot

@DIR_uboot_ipbox@/u-boot.ipbox: bootstrap_gcc @DEPENDS_uboot_ipbox@ $(bootdir)/u-boot-config/u-boot.config
	@PREPARE_uboot_ipbox@
	cp -pR $(bootdir)/u-boot-tuxbox/* @DIR_uboot_ipbox@
	cd @DIR_uboot_ipbox@ && patch -p1 -E -i ../Patches/@DIR_uboot_ipbox@-ipbox.diff
	cp -p $(bootdir)/u-boot-config/u-boot.config @DIR_uboot_ipbox@/include/configs/$(IPBOX_UBOOT_TARGET).h
	$(MAKE) -C @DIR_uboot_ipbox@ $(IPBOX_UBOOT_TARGET)_config
	$(MAKE) -C @DIR_uboot_ipbox@ CROSS_COMPILE=$(target)-
	$(INSTALL) @DIR_uboot_ipbox@/tools/mkimage $(hostprefix)/bin

$(flashprefix)/u-boot.bin \
$(hostprefix)/bin/mkimage: @DEPENDS_uboot_ipbox@ $(bootdir)/u-boot-config/$(IPBOX_UBOOT_TARGET).h
	ln -sf ./$(IPBOX_UBOOT_TARGET).h $(bootdir)/u-boot-config/u-boot.config
	$(MAKE) @DIR_uboot_ipbox@/u-boot.ipbox
	cp @DIR_uboot_ipbox@/System.map $(flashprefix)/u-boot_System.map
	cp @DIR_uboot_ipbox@/u-boot.bin $(flashprefix)/
	@CLEANUP_uboot_ipbox@
	rm $(bootdir)/u-boot-config/u-boot.config

$(flashprefix)/part_uboot.img: $(flashprefix)/u-boot.bin $(hostprefix)/bin/appendbin
	rm -f $@
	$(hostprefix)/bin/appendbin -bs=0x2000 $@ $< `$(IPBOX_FLASH_MAP) blocks uboot` || { rm $@; exit 1; }


# Kernel

$(flashprefix)/vmlinux \
$(flashprefix)/root-squashfs: bootstrap $(IPBOX_DRIVER_DEPENDS)
	rm -rf $@
	m4 -Dflash $(KERNEL_M4) $(kernel_conf) > $(KERNEL_DIR)/.config
	$(MAKE) -C $(KERNEL_DIR) vmlinux modules ARCH=ppc CROSS_COMPILE=$(target)-
	$(INSTALL) -m644 $(KERNEL_BUILD_FILENAME) $(flashprefix)/vmlinux
	$(MAKE) -C $(KERNEL_DIR) modules_install \
		ARCH=ppc CROSS_COMPILE=$(target)- \
		INSTALL_MOD_PATH=$@
	cp $(buildprefix)/linux/System.map $(flashprefix)/kernel_System.map
	$(IPBOX_DRIVER_PREPARE)
	$(INSTALL) -d $(IPBOX_DRIVER_MODDIR)/extra
	$(INSTALL) -m644 $(IPBOX_DRIVER_DIR)/head.ko $(IPBOX_DRIVER_MODDIR)/extra
if ENABLE_MMC
	$(INSTALL) -d $(IPBOX_DRIVER_MODDIR)/kernel/drivers/mmc
	for i in m25p80.ko mmc_spi.ko stb25spi_bitbang.ko stb25spi_devs.ko stb25spi_scp.ko; do \
		$(INSTALL) -v -m644 $(IPBOX_DRIVER_DIR)/$$i $(IPBOX_DRIVER_MODDIR)/kernel/drivers/mmc; \
	done
endif

$(flashprefix)/kernel.img: $(flashprefix)/vmlinux $(hostprefix)/bin/mkimage
	$(target)-objcopy -O binary -R .note -R .comment -S $< $<.bin
	gzip -f9 $<.bin
	$(hostprefix)/bin/mkimage \
		-A ppc -O linux -T kernel -C gzip \
		-a 0 -e 0 -n "Linux Kernel Image" -d $<.bin.gz $@
	rm $<.bin.gz

$(flashprefix)/config.img:
	dd if=/dev/zero of=$@ bs=8K count=`$(IPBOX_FLASH_MAP) blocks config`

$(flashprefix)/welcome.img: ../config/bootlogo.m1v $(hostprefix)/bin/convbmp $(hostprefix)/bin/mkwelcomeimg
	$(hostprefix)/bin/mkwelcomeimg -todo addheader -compress_type 3 -input $< -output $@

$(flashprefix)/var_neutrino.img \
$(flashprefix)/var_enigma.img: \
$(flashprefix)/var_%.img: \
$(flashprefix)/var-% $(hostprefix)/bin/mkfs.jffs2
	$(hostprefix)/bin/mkfs.jffs2 -x lzma -d $< -b -e 65536 -o $@

$(flashprefix)/part_var_neutrino.img \
$(flashprefix)/part_var_enigma.img: \
$(flashprefix)/part_var_%.img: \
$(flashprefix)/var_%.img $(hostprefix)/bin/appendbin
	rm -f $@
	$(hostprefix)/bin/appendbin -bs=0x2000 $@ $< `$(IPBOX_FLASH_MAP) blocks db` || { rm $@; exit 1; }

$(flashprefix)/part_kernel.img: $(flashprefix)/kernel.img $(hostprefix)/bin/appendbin
	rm -f $@
	$(hostprefix)/bin/appendbin -bs=0x2000 $@ $< `$(IPBOX_FLASH_MAP) blocks kernel` || { rm $@; exit 1; }

$(flashprefix)/part_root_neutrino.img \
$(flashprefix)/part_root_enigma.img: \
$(flashprefix)/part_root_%.img: \
$(flashprefix)/root-%.squashfs $(hostprefix)/bin/appendbin
	rm -f $@
	$(hostprefix)/bin/appendbin -bs=0x2000 $@ $< `$(IPBOX_FLASH_MAP) blocks root` || { rm $@; exit 1; }

$(flashprefix)/part_config.img: $(flashprefix)/config.img $(hostprefix)/bin/appendbin
	rm -f $@
	$(hostprefix)/bin/appendbin -bs=0x2000 $@ $< `$(IPBOX_FLASH_MAP) blocks config` || { rm $@; exit 1; }

$(flashprefix)/part_welcome.img: $(flashprefix)/welcome.img $(hostprefix)/bin/appendbin
	rm -f $@
	$(hostprefix)/bin/appendbin -bs=0x2000 $@ $< `$(IPBOX_FLASH_MAP) blocks welcome` || { rm $@; exit 1; }

$(flashprefix)/flash_img_neutrino.img: \
$(flashprefix)/part_root_neutrino.img \
$(flashprefix)/part_config.img \
$(flashprefix)/part_welcome.img \
$(flashprefix)/part_kernel.img \
$(flashprefix)/part_var_neutrino.img \
$(flashprefix)/part_uboot.img
	rm -f $@
	dd if=$(flashprefix)/part_config.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks config` count=`$(IPBOX_FLASH_MAP) blocks config`
	dd if=$(flashprefix)/part_welcome.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks welcome` count=`$(IPBOX_FLASH_MAP) blocks welcome`
	dd if=$(flashprefix)/part_kernel.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks kernel` count=`$(IPBOX_FLASH_MAP) blocks kernel`
	dd if=$(flashprefix)/part_root_neutrino.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks root` count=`$(IPBOX_FLASH_MAP) blocks root`
	dd if=$(flashprefix)/part_var_neutrino.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks db` count=`$(IPBOX_FLASH_MAP) blocks db`
	dd if=$(flashprefix)/part_uboot.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks uboot` count=`$(IPBOX_FLASH_MAP) blocks uboot`

$(flashprefix)/flash_img_enigma.img: \
$(flashprefix)/part_root_enigma.img \
$(flashprefix)/part_config.img \
$(flashprefix)/part_welcome.img \
$(flashprefix)/part_kernel.img \
$(flashprefix)/part_var_enigma.img \
$(flashprefix)/part_uboot.img
	rm -f $@
	dd if=$(flashprefix)/part_config.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks config` count=`$(IPBOX_FLASH_MAP) blocks config`
	dd if=$(flashprefix)/part_welcome.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks welcome` count=`$(IPBOX_FLASH_MAP) blocks welcome`
	dd if=$(flashprefix)/part_kernel.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks kernel` count=`$(IPBOX_FLASH_MAP) blocks kernel`
	dd if=$(flashprefix)/part_root_enigma.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks root` count=`$(IPBOX_FLASH_MAP) blocks root`
	dd if=$(flashprefix)/part_var_enigma.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks db` count=`$(IPBOX_FLASH_MAP) blocks db`
	dd if=$(flashprefix)/part_uboot.img of=$@ bs=8K seek=`$(IPBOX_FLASH_MAP) offset_blocks uboot` count=`$(IPBOX_FLASH_MAP) blocks uboot`

$(flashprefix)/flash_img_low_neutrino.img \
$(flashprefix)/flash_img_low_enigma.img: \
$(flashprefix)/flash_img_low_%.img: \
$(flashprefix)/flash_img_%.img
	dd if=$< of=$@ bs=64K count=64

$(flashprefix)/flash_img_high_neutrino.img \
$(flashprefix)/flash_img_high_enigma.img: \
$(flashprefix)/flash_img_high_%.img: \
$(flashprefix)/flash_img_%.img
	dd if=$< of=$@ bs=64K skip=64 count=64

$(flashprefix)/flash_img_noboot_neutrino.img \
$(flashprefix)/flash_img_noboot_enigma.img: \
$(flashprefix)/flash_img_noboot_%.img: \
$(flashprefix)/flash_img_%.img
	dd if=$< of=$@ bs=64K count=`BLOCK_SIZE=0x10000 $(IPBOX_FLASH_MAP) blocks 0 -2`

$(flashprefix)/flash_img_kernel_root_neutrino.img \
$(flashprefix)/flash_img_kernel_root_enigma.img: \
$(flashprefix)/flash_img_kernel_root_%.img: \
$(flashprefix)/flash_img_%.img
	dd if=$< of=$@ bs=64K skip=`BLOCK_SIZE=0x10000 $(IPBOX_FLASH_MAP) offset_blocks kernel` count=`BLOCK_SIZE=0x10000 $(IPBOX_FLASH_MAP) blocks kernel root`

$(flashprefix)/flash_img_kernel_root_var_neutrino.img \
$(flashprefix)/flash_img_kernel_root_var_enigma.img: \
$(flashprefix)/flash_img_kernel_root_var_%.img: \
$(flashprefix)/flash_img_%.img
	dd if=$< of=$@ bs=64K skip=`BLOCK_SIZE=0x10000 $(IPBOX_FLASH_MAP) offset_blocks kernel` count=`BLOCK_SIZE=0x10000 $(IPBOX_FLASH_MAP) blocks kernel db`

$(flashprefix)/flash_img_kernel_root_var_uboot_neutrino.img \
$(flashprefix)/flash_img_kernel_root_var_uboot_enigma.img: \
$(flashprefix)/flash_img_kernel_root_var_uboot_%.img: \
$(flashprefix)/flash_img_%.img
	dd if=$< of=$@ bs=64K skip=`BLOCK_SIZE=0x10000 $(IPBOX_FLASH_MAP) offset_blocks kernel` count=`BLOCK_SIZE=0x10000 $(IPBOX_FLASH_MAP) blocks kernel uboot`


# serial images

ipbox_serial_imgs_neutrino \
ipbox_serial_imgs_enigma: \
ipbox_serial_imgs_%: \
$(flashprefix)/serial_all_%.img \
$(flashprefix)/serial_all_noboot_%.img \
$(flashprefix)/serial_welcome.img \
$(flashprefix)/serial_kernel.img \
$(flashprefix)/serial_kernel_root_%.img \
$(flashprefix)/serial_kernel_root_var_%.img \
$(flashprefix)/serial_kernel_root_var_uboot_%.img \
$(flashprefix)/serial_root_%.img \
$(flashprefix)/serial_var_%.img \
$(flashprefix)/serial_uboot.img

$(flashprefix)/serial_%: $(flashprefix)/usb_% $(hostprefix)/bin/mkdnimg
	$(hostprefix)/bin/mkdnimg -make serialimg -model_name $(IPBOX_UBOOT_TARGET) -input $< -output $@


# USB images

IPBOX_USB_OPTIONS=-vendor_id 0x00444753 -product_id 0x6c6f6f6b -hw_model $(IPBOX_HW_MODEL) -hw_version 0x00010000

ipbox_usb_imgs_neutrino \
ipbox_usb_imgs_enigma: \
ipbox_usb_imgs_%: \
$(flashprefix)/usb_all_%.img \
$(flashprefix)/usb_all_noboot_%.img \
$(flashprefix)/usb_welcome.img \
$(flashprefix)/usb_kernel.img \
$(flashprefix)/usb_kernel_root_%.img \
$(flashprefix)/usb_kernel_root_var_%.img \
$(flashprefix)/usb_kernel_root_var_uboot_%.img \
$(flashprefix)/usb_root_%.img \
$(flashprefix)/usb_var_%.img \
$(flashprefix)/usb_uboot.img

$(flashprefix)/usb_all_neutrino.img \
$(flashprefix)/usb_all_enigma.img: \
$(flashprefix)/usb_all_%.img: \
$(flashprefix)/flash_img_%.img $(hostprefix)/bin/mkdnimg
	$(hostprefix)/bin/mkdnimg -make usbimg $(IPBOX_USB_OPTIONS) -start_addr `$(IPBOX_FLASH_MAP) start config` -erase_size `$(IPBOX_FLASH_MAP) size config uboot` -image_name all -input $< -output $@

$(flashprefix)/usb_all_noboot_neutrino.img \
$(flashprefix)/usb_all_noboot_enigma.img: \
$(flashprefix)/usb_all_noboot_%.img: \
$(flashprefix)/flash_img_noboot_%.img $(hostprefix)/bin/mkdnimg
	$(hostprefix)/bin/mkdnimg -make usbimg $(IPBOX_USB_OPTIONS) -start_addr `$(IPBOX_FLASH_MAP) start config` -erase_size `$(IPBOX_FLASH_MAP) size config db` -image_name all_noboot -input $< -output $@

$(flashprefix)/usb_welcome.img: $(flashprefix)/welcome.img
	$(hostprefix)/bin/mkdnimg -make usbimg $(IPBOX_USB_OPTIONS) -start_addr `$(IPBOX_FLASH_MAP) start welcome` -erase_size `$(IPBOX_FLASH_MAP) size welcome` -image_name welcome -input $< -output $@

$(flashprefix)/usb_kernel.img: $(flashprefix)/kernel.img $(hostprefix)/bin/mkdnimg
	$(hostprefix)/bin/mkdnimg -make usbimg $(IPBOX_USB_OPTIONS) -start_addr `$(IPBOX_FLASH_MAP) start kernel` -erase_size `$(IPBOX_FLASH_MAP) size kernel` -image_name kernel -input $< -output $@

$(flashprefix)/usb_kernel_root_neutrino.img \
$(flashprefix)/usb_kernel_root_enigma.img: \
$(flashprefix)/usb_kernel_root_%.img: \
$(flashprefix)/flash_img_kernel_root_%.img $(hostprefix)/bin/mkdnimg
	$(hostprefix)/bin/mkdnimg -make usbimg $(IPBOX_USB_OPTIONS) -start_addr `$(IPBOX_FLASH_MAP) start kernel` -erase_size `$(IPBOX_FLASH_MAP) size kernel root` -image_name kernel_root -input $< -output $@

$(flashprefix)/usb_kernel_root_var_neutrino.img \
$(flashprefix)/usb_kernel_root_var_enigma.img: \
$(flashprefix)/usb_kernel_root_var_%.img: \
$(flashprefix)/flash_img_kernel_root_var_%.img $(hostprefix)/bin/mkdnimg
	$(hostprefix)/bin/mkdnimg -make usbimg $(IPBOX_USB_OPTIONS) -start_addr `$(IPBOX_FLASH_MAP) start kernel` -erase_size `$(IPBOX_FLASH_MAP) size kernel db` -image_name kernel_root_db -input $< -output $@

$(flashprefix)/usb_kernel_root_var_uboot_neutrino.img \
$(flashprefix)/usb_kernel_root_var_uboot_enigma.img: \
$(flashprefix)/usb_kernel_root_var_uboot_%.img: \
$(flashprefix)/flash_img_kernel_root_var_uboot_%.img $(hostprefix)/bin/mkdnimg
	$(hostprefix)/bin/mkdnimg -make usbimg $(IPBOX_USB_OPTIONS) -start_addr `$(IPBOX_FLASH_MAP) start kernel` -erase_size `$(IPBOX_FLASH_MAP) size kernel uboot` -image_name kernel_root_db_uboot -input $< -output $@

$(flashprefix)/usb_root_neutrino.img \
$(flashprefix)/usb_root_enigma.img: \
$(flashprefix)/usb_root_%.img: \
$(flashprefix)/root-%.squashfs $(hostprefix)/bin/mkdnimg
	$(hostprefix)/bin/mkdnimg -make usbimg $(IPBOX_USB_OPTIONS) -start_addr `$(IPBOX_FLASH_MAP) start root` -erase_size `$(IPBOX_FLASH_MAP) size root` -image_name root -input $< -output $@

$(flashprefix)/usb_var_neutrino.img \
$(flashprefix)/usb_var_enigma.img: \
$(flashprefix)/usb_var_%.img: \
$(flashprefix)/var_%.img $(hostprefix)/bin/mkdnimg
	$(hostprefix)/bin/mkdnimg -make usbimg $(IPBOX_USB_OPTIONS) -start_addr `$(IPBOX_FLASH_MAP) start db` -erase_size `$(IPBOX_FLASH_MAP) size db` -image_name db -input $< -output $@

$(flashprefix)/usb_uboot.img: $(flashprefix)/u-boot.bin $(hostprefix)/bin/mkdnimg
	$(hostprefix)/bin/mkdnimg -make usbimg $(IPBOX_USB_OPTIONS) -start_addr `$(IPBOX_FLASH_MAP) start uboot` -erase_size `$(IPBOX_FLASH_MAP) size uboot` -image_name uboot -input $< -output $@
