# meta-renesas-ai #
This OpenEmbedded/Yocto layer collector adds AI tools support to Renesas RZ/G1
and RZ/G2 platforms.

#### For RZ/G1 ####
The layers should be used with the official Renesas RZ/G1 Yocto Poky BSP based
on the CIP Kernel:  
URI: **https://github.com/renesas-rz/meta-renesas.git**  
tag: certified-linux-v2.1.9 (79bd2782cfb9ddc1760f3fea3d4fc258c20dc552)

#### For RZ/G2 ####
The layers should be used with the official Renesas RZ/G2 Yocto Poky BSP based
on the CIP Kernel:  
URI: **https://github.com/renesas-rz/meta-rzg2.git**  
tag: BSP-1.0.8 (b11b9471c31d8231a43c7eeeed8702e9873841ae)

#### For RZ/G2L ####
The layers should be used with the official Renesas RZ/G2L Yocto Poky BSP:  
URI: **https://github.com/renesas-rz/meta-rzg2/tree/dunfell/rzg2l**  
tag: rzg2l_bsp_v1.1-update1 (61f6dcb61ac89b92c93a9d8627b837f59cf307d6)

For each AI tool, please refer to **meta-${AI\_TOOL\_NAME}/README.md**. For
example:  
*meta-tensorflow-lite/README.md*


This project comes with template files to make it easier for the user to quickly
integrate their specific application with the specific AI tool. Only specific
platforms are supported, therefore template files are machine specific and can
be found under:  
**meta-${AI\_TOOL\_NAME}/templates/${MACHINE}**  


Copying *local.conf* and *bblayers.conf* from the templates directory to your
build conf directory is usually the first thing the user wants to do, but
the configuration must be inspected and further customized according to the
project requirements.

Before using the configuration files from the desired templates directory,
please make sure you have read and understood the terms and conditions found
in the [Licensing](#licensing) section.

### Supported Frameworks/Versions ###

| Framework       | Version   | Parser(s)                              | Inference Hardware               |
| :-------------- | :-------- | :------------------------------------- | :------------------------------- |
| ArmNN           | v21.05    | ONNX<br>TensorFlow Lite                | CPU                              |
| ONNX Runtime    | v1.8.0    | ONNX                                   | CPU                              |
| TensorFlow Lite | v2.3.1    | TensorFlow Lite                        | CPU                              |

### Supported Embedded Platforms ###

| SoC            | Platform                 |
| :------------- | :----------------------- |
| Renesas RZ/G2H | HopeRun hihope-rzg2h     |
| Renesas RZ/G2M | HopeRun hihope-rzg2m     |
| Renesas RZ/G2N | HopeRun hihope-rzg2n     |
| Renesas RZ/G2E | Silicon Linux ek874      |
| Renesas RZ/G2L | Renesas rzg2l-smarc evk  |
| Renesas RZ/G1H | iWave Systems iwg21m     |
| Renesas RZ/G1M | iWave Systems iwg20m-g1m |
| Renesas RZ/G1E | iWave Systems iwg22m     |

### Build Script ###
A simple build script has been created to manage the build process.  
Before running the script you will need to download the relevant proprietary
libraries from the Renesas website. See the Renesas RZ/G[12] BSP readme file for
details on how to do this.

Run `./scripts/build-rzg-ai-bsp.sh -h` to get an overview on how to use the
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

**meta-rzg2 patch for RZ/G2L BSP**  
There is a bug in the RZ/G2L BSP where a BBMASK for the recipes-debian directory
isn't formatted correctly.

This is fixed by applying *patches/meta-rzg2/dunfell-rzg2l/0001-cip-core.inc-Fix-recipes-debian-BBMASK.patch*.

```
cd meta-rzg2
git am ../meta-renesas-ai/patches/meta-rzg2/dunfell-rzg2l/0001-cip-core.inc-Fix-recipes-debian-BBMASK.patch
```

This only needs to be done when building for the *smarc-rzg2l* platform.

## LICENSING ##

This project is licensed under the terms of the MIT license (please see file
*COPYING.MIT* in this directory for further details).

The configuration files found under:
```
meta-*/templates/*/local.conf
```
show how to whitelist the commercial license flag for graphics packages.
This is needed to add full video encoding/decoding support to the BSP. 
For example for the RZ/G1H:
```
LICENSE_FLAGS_WHITELIST = "commercial_gstreamer1.0-libav commercial_gstreamer1.0-omx"
```

By editing these commented lines in the template files coming from this repository,
the user agrees to the terms and conditions from the licenses of the packages
that are installed into the final image and that are covered by a commercial license.

The user also acknowledges that it's their responsibility to make sure
they hold the right to use code protected by commercial agreements, whether
the commercially protected packages are selected by Renesas' BSPs or by them.

Finally, the user acknowledges that it's their responsibility to make sure
they hold the right to copy, use, modify, and re-distribute the intellectual
property offered by this collection of meta-layers.

**Note:** Without uncommenting the `LICENSE_FLAGS_WHITELIST` lines the BSP build will fail.  


---

Send pull requests, patches, comments or questions to:  
[chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).


Maintainer:  
**Chris Paterson** [chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).
