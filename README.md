# meta-renesas-ai #
This OpenEmbedded/Yocto layer collector adds AI tools support to Renesas RZ/G1
and RZ/G2 platforms.

#### For RZ/G1 ####
The layers should be used with the official Renesas RZ/G1 Yocto Poky BSP based
on the CIP Kernel:  
URI: **https://github.com/renesas-rz/meta-renesas.git**  
tag: certified-linux-v2.1.5 (8c60fa1de1ffc3fd9db2b8005be0f7ae17f6d691)

#### For RZ/G2 ####
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

### Supported Frameworks/Versions ###

| Framework       | Version   | Parser(s)                              | Inference Hardware               |
| :-------------- | :-------- | :------------------------------------- | :------------------------------- |
| ArmNN           | v19.08.01 | ONNX<br>TensorFlow<br>TensorFlow Lite  | CPU                              |
| Caffe2          | v0.8.1    | Caffe2                                 | CPU                              |
| ONNX Runtime    | v1.1.2    | ONNX                                   | CPU                              |
| OpenCV          | v4.1.1    | Caffe<br>DarkNet<br>ONNX<br>TensorFlow | CPU                              |
| PyTorch         | v1.5.0    | PyTorch                                | CPU                              |
| TensorFlow      | v2.0.2    | TensorFlow                             | CPU                              |
| TensorFlow Lite | v2.0.2    | TensorFlow Lite                        | CPU<br>Coral USB TPU (diploria2) |

### Supported Embedded Platforms ###

| SoC            | Platform                 |
| :------------- | :----------------------- |
| Renesas RZ/G2M | HopeRun hihope-rzg2m     |
| Renesas RZ/G2N | HopeRun hihope-rzg2n     |
| Renesas RZ/G2E | Silicon Linux ek874      |
| Renesas RZ/G1H | iWave Systems iwg21m     |
| Renesas RZ/G1M | iWave Systems iwg20m-g1m |
| Renesas RZ/G1E | iWave Systems iwg22m     |

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

**rzg[2]-modules-common.inc patches**
Depending on the build system it is sometimes possible for there to be a build
failure when more then one out-of-tree Kernel module is built at the same time:
`"/bin/sh: scripts/mod/modpost: Permission denied"`.

This race condition can be avoided by locking access to kernel_scripts so that
only one module can use modpost at the same time.

The patches *patches/meta-renesas/0001-include-rzg-modules-common-Fix-race-condition-in-ker.patch*
and *patches/meta-rzg2/0001-include-rzg2-modules-common-Fix-race-condition-in-ke.patch*
can be applied to *meta-renesas* and *meta-rzg2* respectively to apply the above
fix.

```
cd meta-renesas
git am ../meta-renesas-ai/patches/meta-renesas/0001-include-rzg-modules-common-Fix-race-condition-in-ker.patch
cd -
cd meta-rzg2
git am ../meta-renesas-ai/patches/meta-rzg2/0001-include-rzg2-modules-common-Fix-race-condition-in-ke.patch
```

---


This project is licensed under the terms of the MIT license (please see file
*COPYING.MIT* in this directory for further details).


Send pull requests, patches, comments or questions to:  
[chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).


Maintainer:  
**Chris Paterson** [chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).
