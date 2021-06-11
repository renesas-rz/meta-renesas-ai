# meta-renesas-ai #
This OpenEmbedded/Yocto layer collector adds AI tools support to Renesas RZ/G1
and RZ/G2 platforms.

#### For RZ/G1 ####
The layers should be used with the official Renesas RZ/G1 Yocto Poky BSP based
on the CIP Kernel:  
URI: **https://github.com/renesas-rz/meta-renesas.git**  
tag: certified-linux-v2.1.8 (3a4fae402a34c92fd231e1b8c077a6964a90186f)

The meta-rzg1-gcc-linaro meta-layer should be used when including TensorFlow
v2.3+ as GCC v7.3 is required. Read *meta-rzg1-gcc-linaro/README.md* for more
details.

#### For RZ/G2 ####
The layers should be used with the official Renesas RZ/G2 Yocto Poky BSP based
on the CIP Kernel:  
URI: **https://github.com/renesas-rz/meta-rzg2.git**  
tag: BSP-1.0.7 (5ddd7aac729dac64d362e6ee5aa291d9f44dea0f)

#### For RZ/G2L ####
The layers should be used with the official Renesas RZ/G2L Yocto Poky BSP:  
URI: **https://github.com/renesas-rz/meta-rzg2/tree/dunfell/rzg2l**  
commit: 2313d60eb75e5c86ce3e42ad378c8473f8e95c88

For each AI tool, please refer to **meta-${AI\_TOOL\_NAME}/README.md**. For
example:  
*meta-tensorflow/README.md*


This project comes with template files to make it easier for the user to quickly
integrate their specific application with the specific AI tool. Only specific
platforms are supported, therefore template files are machine specific and can
be found under:  
**meta-${AI\_TOOL\_NAME}/templates/${MACHINE}**  


Copying *local.conf* and *bblayers.conf* from the templates directory to your
build conf directory is usually the first thing the user wants to do, but
the configuration must be inspected and further customized according to the
project requirements.

### Supported Frameworks/Versions ###

| Framework       | Version   | Parser(s)                              | Inference Hardware               |
| :-------------- | :-------- | :------------------------------------- | :------------------------------- |
| ArmNN           | v21.02    | ONNX<br>TensorFlow<br>TensorFlow Lite  | CPU                              |
| Caffe2          | v0.8.1    | Caffe2                                 | CPU                              |
| ONNX Runtime    | v1.8.0    | ONNX                                   | CPU                              |
| OpenCV          | v4.1.1    | Caffe<br>DarkNet<br>ONNX<br>TensorFlow | CPU                              |
| PyTorch         | v1.5.1    | PyTorch                                | CPU                              |
| TensorFlow      | v2.3.1    | TensorFlow                             | CPU                              |
| TensorFlow Lite | v2.3.1    | TensorFlow Lite                        | CPU<br>Coral USB TPU (frogfish) |

### Supported Embedded Platforms ###

| SoC            | Platform                 |
| :------------- | :----------------------- |
| Renesas RZ/G2H | HopeRun hihope-rzg2h     |
| Renesas RZ/G2M | HopeRun hihope-rzg2m     |
| Renesas RZ/G2N | HopeRun hihope-rzg2n     |
| Renesas RZ/G2E | Silicon Linux ek874      |
| Renesas RZ/G1H | iWave Systems iwg21m     |
| Renesas RZ/G1M | iWave Systems iwg20m-g1m |
| Renesas RZ/G1E | iWave Systems iwg22m     |

### Build Script ###
A simple build script has been created to manage the build process.  
Before running the script you will need to download the relevant proprietary
libraries from the Renesas website. See the Renesas RZ/G[12] BSP readme file for details on how to do this.

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

---


This project is licensed under the terms of the MIT license (please see file
*COPYING.MIT* in this directory for further details).


Send pull requests, patches, comments or questions to:  
[chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).


Maintainer:  
**Chris Paterson** [chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).
