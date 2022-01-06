do_install_append () {
	cat>>${D}${sysconfdir}/fstab<<-EOF
	# Enable swap area (if present) for large AI models
	/mnt/swap	none	swap	sw	0	0
	EOF
}
