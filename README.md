# meta-renesas-ai #
This OpenEmbedded/Yocto layer collector adds AI tools support to Renesas RZ/G2
platforms.

#### For RZ/G2 family ####
The layers should be used with the official Renesas RZ/G2 Yocto Poky BSP based
on the CIP Kernel:  
URI: **https://github.com/renesas-rz/meta-rzg2.git**  
tag: BSP-1.0.10-update1 (85d5f8cc554413fc19e4fff43cb0c027f55d0778)

#### For RZ/G2L family ####
The layers should be used with the official Renesas RZ/G2L Yocto Poky BSP:  
URI: **https://github.com/renesas-rz/meta-rzg2/tree/dunfell/rzg2l**  
tag: rzg2l_bsp_v1.4 (fe55191cb573c7db4cf71a5e65848434dbdf6b31)

For each AI tool, please refer to **meta-${AI\_TOOL\_NAME}/README.md**. For
example:  
*meta-tensorflow-lite/README.md*


This project comes with template files for the RZ/G2 and RZ/G2L families. The
templates can be found under:  
**templates/${FAMILY}**  


Copying *local.conf* and *bblayers.conf* from the templates directory to your
build conf directory is usually the first thing the user wants to do, but
the configuration must be inspected and further customized according to the
project requirements. This can be done by running the configuration script
which will add the specified platform and AI framework to the configuration
files.

Before using the configuration files from the templates directory,
please make sure you have read and understood the terms and conditions found
in the [Licensing](#licensing) section.

### Supported Frameworks/Versions ###

| Framework                                       | Version   | Parser(s)                                 | Inference Hardware |
| :---------------------------------------------- | :-------- | :---------------------------------------- | :----------------- |
| ArmNN                                           | v21.05    | ONNX (v1.6.0)<br>TensorFlow Lite (v2.3.1) | CPU                |
| ArmNN (smarc-rzg2l, smarc-rzg2lc, smarc-rzg2ul) | v22.02    | ONNX (v1.6.0)<br>TensorFlow Lite (v2.5.3) | CPU<br>GPU         |
| ONNX Runtime                                    | v1.8.0    | ONNX                                      | CPU                |
| TensorFlow Lite                                 | v2.3.1    | TensorFlow Lite                           | CPU                |
| TensorFlow Lite                                 | v2.5.3    | TensorFlow Lite                           | CPU                |

### Supported Embedded Platforms ###

| SoC             | Platform                 |
| :-------------- | :----------------------- |
| Renesas RZ/G2H  | HopeRun hihope-rzg2h     |
| Renesas RZ/G2M  | HopeRun hihope-rzg2m     |
| Renesas RZ/G2N  | HopeRun hihope-rzg2n     |
| Renesas RZ/G2E  | Silicon Linux ek874      |
| Renesas RZ/G2L  | Renesas smarc-rzg2l evk  |
| Renesas RZ/G2LC | Renesas smarc-rzg2lc evk |
| Renesas RZ/G2UL | Renesas smarc-rzg2ul evk |

### Build Script ###
A simple build script has been created to manage the build process.  
Before running the script you will need to download the relevant proprietary
libraries from the Renesas website. See the Renesas RZ/G2 and RZ/G2L BSP readme
files for details on how to do this.

Run `./scripts/build-rzg-ai-bsp.sh -h` to get an overview on how to use the
script.

### Configuration Script ###
A simple configuration script has been created to set up the configuration
files and add the necessary dependencies.  
Before running the script you will need to source the yocto environment and
copy over the configuration templates for the appropriate device family from
the templates/ directory.  
This script is used automatically by `build-rzg-ai-bsp.sh` but can be run
independently if required.

Run `./scripts/set-config-files.sh -h` to get an overview on how to use the
script.

---

## Notes ##
**Proxies**  
If working behind a proxy, make sure the environment of the shell you are
running bitbake from contains *HTTP\_PROXY* and *HTTPS\_PROXY* environment
variables, set according to your proxy configuration.


**Using Large Models**  
Due to the limited memory size on some platforms, large pre-trained models could
cause out of memory issues. To overcome this memory limitation, a swap file can
used.  
To include swap support add the following to local.conf:  
```
IMAGE_INSTALL_append = " mkswap"
```


By default, this will create and enable a 2048 MB swapfile.  


If needed, the size of the swap file can be set (in MB) in local.conf:  
```
SWAP_SIZE = "512"
```

## LICENSING ##

This project is licensed under the terms of the MIT license (please see file
*COPYING.MIT* in this directory for further details).

The configuration files found under:
```
meta-*/templates/*/local.conf
```
This is needed to add full video encoding/decoding support to the BSP.  
For example for the RZ/G2L:
```
LICENSE_FLAGS_WHITELIST = "commercial_gstreamer1.0-libav commercial_gstreamer1.0-plugins-ugly commercial_ffmpeg commercial_mpeg2dec commercial_faac commercial_faad2 commercial_x264"
```

By editing these commented lines in the template files coming from this
repository, the user agrees to the terms and conditions from the licenses of the
packages that are installed into the final image and that are covered by a
commercial license.

The user also acknowledges that it's their responsibility to make sure
they hold the right to use code protected by commercial agreements, whether
the commercially protected packages are selected by Renesas' BSPs or by them.

Finally, the user acknowledges that it's their responsibility to make sure
they hold the right to copy, use, modify, and re-distribute the intellectual
property offered by this collection of meta-layers.

**Note:** Without uncommenting the `LICENSE_FLAGS_WHITELIST` lines the BSP build
will fail.

---

Send pull requests, patches, comments or questions to:  
[chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).


Maintainer:  
**Chris Paterson** [chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).
