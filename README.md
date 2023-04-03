# meta-renesas-ai #
This OpenEmbedded/Yocto layer collector adds AI tools support to the Renesas
RZ/G2 and RZ/G2L families of SoCs and reference platforms.

#### For RZ/G2 and RZ/G2L families ####
The layers should be used with the official Renesas RZ/G2 Yocto Poky BSP based
on the CIP Kernel:\
URI: **https://github.com/renesas-rz/meta-renesas.git** \
tag: BSP-3.0.1 (b5783592961561c9bfdfe0144540d7eccee44bb8)


For each AI tool, please refer to the documentaion provided in [docs](./docs/).


This project comes with joint template files for all of the supported platforms.
The templates can be found under **docs/templates/rzg2/**.

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

| Framework       | Version   | Parser(s)                                 | Inference Hardware                     |
| :-------------- | :-------- | :---------------------------------------- | :------------------------------------- |
| ArmNN           | v22.02    | ONNX (v1.6.0)<br>TensorFlow Lite (v2.5.3) | CPU<br>GPU (smarc-rzg2l, smarc-rzg2lc) |
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
| Renesas RZ/G2UL | Renesas smarc-rzg2ul evk |

### Build Script ###
A simple build script has been created to manage the build process.\
Before running the script you will need to download the relevant proprietary
libraries from the Renesas website. See the Renesas BSP readme file for details
on how to do this.

Run `./scripts/build-rzg-ai-bsp.sh -h` to get an overview on how to use the
script.

### Configuration Script ###
A simple configuration script has been created to set up the configuration
files and add the necessary dependencies.\
Before running the script you will need to source the yocto environment and
copy over the configuration templates from the **docs/templates/rzg2/** directory.\
This script is used automatically by `build-rzg-ai-bsp.sh` but can be run
independently if required.

Run `./scripts/set-config-files.sh -h` to get an overview on how to use the
script.

### LAVA Test Job Submission Script ###
The 'submit-lava-job.sh' script has been created to manage the creation and
submission of LAVA test jobs. These test jobs run a number of test cases to
verify functionality of the AI BSP. The test scripts are provided by the
*ai-tests* recipe.

Run `./scripts/submit-lava-job.sh -h` to get an overview on how to use the
script.

The script depends on the *${BUILD\_JOB\_ID}* variable to be set in the
environment, as it uses this in order to set the correct URL to the GitLab CI
build artifacts that LAVA needs to download. See *.gitlab-ci.yml* for an example
of how this is done in this project.

If *${BUILD\_JOB\_ID}* and *${CI\_PROJECT\_URL}* are set manually it is possible
to run this script outside of a GitLab CI environment.

---

## Notes ##
**Proxies**\
If working behind a proxy, make sure the environment of the shell you are
running bitbake from contains *HTTP\_PROXY* and *HTTPS\_PROXY* environment
variables, set according to your proxy configuration.


**Using Large Models**\
Due to the limited memory size on some platforms, large pre-trained models could
cause out of memory issues. To overcome this memory limitation, a swap file can
used.\
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

The configuration files provided in the RZ/G BSP include the following
whitelisted licenses that the user should be aware of before using this project:
```
LICENSE_FLAGS_WHITELIST = " \
	commercial_gstreamer1.0-plugins-ugly commercial_mpeg2dec \
	commercial_gst-plugins-bad commercial_faad2 commercial_faac \
	commercial_gstreamer1.0-libav commercial_ffmpeg commercial_x264 \
"
```
These are needed to add full video encoding/decoding support to the BSP.

By using this project the user agrees to the terms and conditions from the
licenses of the packages that are installed into the final image and that are
covered by a commercial license. The user also acknowledges that it's their
responsibility to make sure they hold the right to use code protected by
commercial agreements, whether the commercially protected packages are selected
by Renesas' BSPs or by them.

Finally, the user acknowledges that it's their responsibility to make sure
they hold the right to copy, use, modify, and re-distribute the intellectual
property offered by this meta-layer.

---

Send pull requests, patches, comments or questions to:\
[chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).


Maintainer:\
**Chris Paterson** [chris.paterson2@renesas.com](mailto:chris.paterson2@renesas.com).
