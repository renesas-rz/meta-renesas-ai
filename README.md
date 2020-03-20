# meta-renesas-ai #
This OpenEmbedded/Yocto layer collector adds AI tools support to Renesas RZ/G1
and RZ/G2 platforms.

### For RZ/G1 ###
The layers should be used with the official Renesas RZ/G1 Yocto Poky BSP based
on the CIP Kernel:  
URI: **https://github.com/renesas-rz/meta-renesas.git**  
Revision: certified-linux-v2.1.4 (950981698a9fc62a3738de4050a6f633bb18136f)

### For RZ/G2 ###
The layers should be used with the official Renesas RZ/G2 Yocto Poky BSP based
on the CIP Kernel:
URI: **https://github.com/renesas-rz/meta-rzg2.git**  
tag: BSP-1.0.3 (55713fde8ce5dba2ca0fd68d82b23c660de795f2)


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


Supported AI tools:  
- TensorFlow (v2.0.0)  
- TensorFlow Lite (v2.0.0)  
- Caffe2 (v0.8.1)  
- Arm Neural Network SDK (v19.08.01)  
- ONNX Runtime (v1.1.2)  
- OpenCV (v4.1.1)  
- Google Coral USB TPU (diploria2)


Supported Platforms:  
- Renesas RZ/G1M iwg20m  
- Renesas RZ/G1H iwg21m  
- Renesas RZ/G1E iwg22m  
- Renesas RZ/G2M hihope-rzg2m  
- Renesas RZ/G2E ek874

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

---


This project is licensed under the terms of the MIT license (please see file
*COPYING.MIT* in this directory for further details).


Send pull requests, patches, comments or questions to:  
[chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).


Maintainer:  
**Chris Paterson** [chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).
