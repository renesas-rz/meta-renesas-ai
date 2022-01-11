SRC_URI_remove = " gitsm://github.com/renesas-rcar/gst-plugins-good.git;branch=RCAR-GEN3e/1.16.3;name=base"
SRC_URI_append = " gitsm://github.com/renesas-rcar/gst-plugins-good.git;protocol=https;branch=RCAR-GEN3e/1.16.3;name=base"

do_populate_lic[rdeptask] = "do_configure"

do_configure_prepend() {
	cd ${S}
	./autogen.sh --noconfigure
	cd ${B}
}

