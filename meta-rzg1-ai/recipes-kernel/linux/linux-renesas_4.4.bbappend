configure_cma_iwg20m-g1m_append () {
	kernel_configure_variable_val CMA_SIZE_MBYTES 128
	kernel_configure_variable NFS_SWAP y
}

configure_cma_iwg21m_append () {
	kernel_configure_variable_val CMA_SIZE_MBYTES 128
	kernel_configure_variable NFS_SWAP y
}

configure_cma_iwg22m_append () {
	kernel_configure_variable_val CMA_SIZE_MBYTES 64
	kernel_configure_variable NFS_SWAP y
}
