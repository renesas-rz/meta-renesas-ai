# meta-rzg1-gcc-linaro

To compile TensorFlow v2.3.1 Linaro GCC 7.3 is required. This is not included 
in the RZ/G1 BSP so must be added as part of meta-renesas-ai. Without using
this layer for TensorFlow compilation, an exotic linking error will occur.

The following lines must be added to the local.conf to select this compiler:
```
GCCVERSION = "linaro-7.3"
SDKGCCVERSION = "${GCCVERSION}"
```

This code was orginaly extracted from the RZ/G2 BSP available from:
https://github.com/renesas-rz/meta-rzg2.git

Minor modifications were made to allow functionality with the RZ/G1, however
credit remains with the original authors.
