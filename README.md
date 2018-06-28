# meta-renesas-ai
This OpenEmbedded/Yocto layer collector adds AI tools support to Renesas RZ/G1
platforms.


The layers should be used with the official Renesas RZ/G Yocto Poky BSP based
on the CIP Kernel:  
URI: **https://github.com/renesas-rz/meta-renesas.git**  
Revision: certified-linux-v2.0.6 (8e6e7c420f17546c49c773b9ec1f346616c1fa6d)


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
- TensorFlow v1.2.0  
- TensorFlow Lite v1.7.0  
- Caffe2 v0.7.0  


Supported Platforms:  
- Renesas RZ/G1M iwg20m  
- Renesas RZ/G1H iwg21m  
- Renesas RZ/G1E iwg22m  


---

**Note**  
If working behind a proxy, make sure the environment of the shell you are
running bitbake from contains *HTTP\_PROXY* and *HTTPS\_PROXY* environment
variables, set according to your proxy configuration.

---


This project is licensed under the terms of the MIT license (please see file
*COPYING.MIT* in this directory for further details).


Send pull requests, patches, comments or questions to:  
[chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).


Maintainer:  
**Chris Paterson** [chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).
