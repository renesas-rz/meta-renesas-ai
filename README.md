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
tag: rzg2l_bsp_v1.3-update1 (de2774adf5a0852b03e8842aec794f2825ffc11b)

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

| Framework       | Version   | Parser(s)                                 | Inference Hardware                     |
| :-------------- | :-------- | :---------------------------------------- | :------------------------------------- |
| ArmNN           | v21.05    | ONNX (v1.6.0)<br>TensorFlow Lite (v2.3.1) | CPU<br>GPU (smarc-rzg2l, smarc-rzg2lc) |
| ONNX Runtime    | v1.8.0    | ONNX                                      | CPU                                    |
| TensorFlow Lite | v2.5.3    | TensorFlow Lite                           | CPU                                    |

### Supported Embedded Platforms ###

| SoC             | Platform                 |
| :-------------- | :----------------------- |
| Renesas RZ/G2H  | HopeRun hihope-rzg2h     |
| Renesas RZ/G2M  | HopeRun hihope-rzg2m     |
| Renesas RZ/G2N  | HopeRun hihope-rzg2n     |
| Renesas RZ/G2E  | Silicon Linux ek874      |
| Renesas RZ/G2L  | Renesas smarc-rzg2l evk  |
| Renesas RZ/G2LC | Renesas smarc-rzg2lc evk |

### Build Script ###
A simple build script has been created to manage the build process.  
Before running the script you will need to download the relevant proprietary
libraries from the Renesas website. See the Renesas RZ/G2 BSP readme file for
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

**meta-rzg2 patches for RZ/G2L BSP**  
There is a bug when trying to build the SDK for core-image-qt images.

This is fixed by applying *patches/meta-rzg2/dunfell-rzg2l/0001-Enable-RZ-G2L-Qt-SDK-builds.patch*.


```
cd meta-rzg2
git am ../meta-renesas-ai/patches/meta-rzg2/dunfell-rzg2l/0001-Enable-RZ-G2L-Qt-SDK-builds.patch
```

This only needs to be done when building for the *smarc-rzg2l* and
*smarc-rzg2lc* platforms.

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
