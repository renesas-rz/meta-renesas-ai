do_install_append () {
	if [ "${MACHINE}" = "iwg22m" ] || [ "${MACHINE}" = "iwg21m" ] || [ "${MACHINE}" = "iwg20m" ]; then
		cat>>${D}${sysconfdir}/fstab<<-EOF
		# Enable swap area (if present) for large AI models
		/mnt/swap	none	swap	sw	0	0
		EOF
	fi
}
