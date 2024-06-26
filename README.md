# meta-renesas-ai #
This OpenEmbedded/Yocto layer, nicknamed the "RZ/G AI BSP", adds FOSS
AI tools support to the Renesas RZ/G2, RZ/G2L and RZ/V2L families of SoCs and reference
platforms.

This meta-layer should be used with the official Renesas RZ/G2 Yocto Poky BSP
based on the CIP Kernel:\
URI: **https://github.com/renesas-rz/meta-renesas.git** \
tag: BSP-3.0.6 (0f2f02c4cff3bfc9fed5c0671f3e3165608122b0)

## Supported Frameworks/Versions ##

| Framework       | Version   | Parser(s)                                  | Inference Hardware                                  |
| :-------------- | :-------- | :----------------------------------------- | :-------------------------------------------------- |
| ArmNN           | v24.05    | ONNX (v1.6.0)<br>TensorFlow Lite (v2.15.1) | CPU<br>GPU (smarc-rzg2l, smarc-rzg2lc, smarc-rzv2l) |
| ONNX Runtime    | v1.8.0    | ONNX                                       | CPU                                                 |
| TensorFlow Lite | v2.15.1   | TensorFlow Lite                            | CPU                                                 |

## Supported Embedded Platforms ##

| SoC             | Platform                 |
| :-------------- | :----------------------- |
| Renesas RZ/G2H  | HopeRun hihope-rzg2h     |
| Renesas RZ/G2M  | HopeRun hihope-rzg2m     |
| Renesas RZ/G2N  | HopeRun hihope-rzg2n     |
| Renesas RZ/G2E  | Silicon Linux ek874      |
| Renesas RZ/G2L  | Renesas smarc-rzg2l evk  |
| Renesas RZ/G2LC | Renesas smarc-rzg2lc evk |
| Renesas RZ/G2UL | Renesas smarc-rzg2ul evk |
| Renesas RZ/V2L  | Renesas smarc-rzv2l evk  |

## Documentation ##
For each AI tool, please refer to the documentaion provided in [docs](./docs/).

## Dependencies ##
This meta-layer depends on the following:

* Poky
  * URI: https://git.yoctoproject.org/poky
  * layers: meta, meta-poky, meta-yocto-bsp
  * branch: dunfell
  * revision: a9e3cc3b9eab7a83c715bb8440454e8fea852c2a
* OpenEmbedded
  * URI: https://git.openembedded.org/meta-openembedded
  * layers: meta-oe, meta-python, meta-multimedia
  * branch: dunfell
  * revision: daa4619fe3fbf8c28f342c4a7163a84a330f7653
* GPLv2
  * URI: https://git.yoctoproject.org/meta-gplv2
  * layers: meta-gplv2
  * branch: dunfell
  * revision: 60b251c25ba87e946a0ca4cdc8d17b1cb09292ac
* Qt5
  * URI: https://github.com/meta-qt5/meta-qt5
  * layers: meta-qt5
  * revision: c1b0c9f546289b1592d7a895640de103723a0305
* RZ/G BSP
  * URI: https://github.com/renesas-rz/meta-renesas
  * layers: meta-rz-common, meta-rzg2h, meta-rzg2l, meta-rzv2l
  * branch: dunfell/rz
  * revision: 0f2f02c4cff3bfc9fed5c0671f3e3165608122b0

## Patches for other meta-layers ##
In order to build meta-renesas-ai some external meta-layers need to be patched.

The patches below should be applied to the relevant meta-layer before a build is
started. This is done automatically by the *build-rzg-ai-bsp.sh* build script.

### meta-qt5 ###
* *0001-layer.conf-Add-LAYERSERIES_COMPAT-for-dunfell.patch*

## Build Instructions ##
Below are the instructions to follow if you want to build the RZ/G AI BSP
manually. Alternitively the scripts in the [scripts](./scripts/) directory can
be used to automate the process.

### 1) OS Dependencies ###
The RZ/G BSP is based on Yocto Dunfell. As such, a build system supported by
Dunfell should be used. We test with Ubuntu 20.04 LTS.

Read the Yocto [System Requirements](https://docs.yoctoproject.org/3.1.24/ref-manual/ref-system-requirements.html)
for full details.

### 2) Download Source Code ###
```bash
git clone https://git.yoctoproject.org/poky
cd poky
git checkout dunfell-23.0.31
cd ..

git clone https://git.openembedded.org/meta-openembedded
cd meta-openembedded
git checkout daa4619fe3fbf8c28f342c4a7163a84a330f7653
cd ..

git clone https://git.yoctoproject.org/meta-gplv2
cd meta-gplv2
git checkout 60b251c25ba87e946a0ca4cdc8d17b1cb09292ac
cd ..

git clone  https://github.com/meta-qt5/meta-qt5
cd meta-qt5
git checkout c1b0c9f546289b1592d7a895640de103723a0305
git am ../meta-renesas-ai/patches/meta-qt5/*.patch
cd ..

git clone https://github.com/renesas-rz/meta-renesas
cd meta-renesas
git checkout BSP-3.0.6
cd ..
```

### 3) Download Proprietary Libraries ###
The graphics and multimedia libraries can be downloaded from the Renesas website.
[This page](https://www.renesas.com/us/en/products/microcontrollers-microprocessors/rz-mpus/rzg-linux-platform/rzg-marketplace/verified-linux-package/rzg-verified-linux-package#Download)
lists the packages for the latest RSZ/G BSP, however direct links are below for
the versions tested with this project. Note that an account will be needed to
download the libraries as an ELA must be signed.

For hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874:
* [RTK0EF0045Z0022AZJ-v1.0.2_EN.zip](https://www.renesas.com/us/en/document/sws/rz-mpu-multimedia-package-evaluation-version-v102-verified-linux-package-rzg2h-rzg2m-rzg2n-and-rzg2e?r=1597486)

For smarc-rzg2l, smarc-rzv2l:
* [RTK0EF0045Z13001ZJ-v1.2.2_EN.zip](https://www.renesas.com/us/en/document/swo/rz-mpu-graphics-library-evaluation-version-v122-rzg2l-and-rzg2lc-rtk0ef0045z13001zj-v122xxzip?r=1522761)
* [RTK0EF0045Z15001ZJ-v1.2.1_EN.zip](https://www.renesas.com/us/en/document/swo/rz-mpu-video-codec-library-evaluation-version-v121-rzg2l-rtk0ef0045z15001zj-v121xxzip?r=1535641)

For smarc-rzg2lc:
* [RTK0EF0045Z13001ZJ-v1.2.2_EN.zip](https://www.renesas.com/us/en/document/swo/rz-mpu-graphics-library-evaluation-version-v122-rzg2l-and-rzg2lc-rtk0ef0045z13001zj-v122xxzip?r=1522761)

No packages are required for devices not listed above.

The above zip files should be extracted, and the `meta-rz-features*.tar.gz`
archives found within should be extracted to the working directory alongside the
other meta-layers in a directory called `meta-rz-features`.

### 4) Configure Build ###
Once all code has been downloaded, the working directory should look like this:
```bash
$ tree -L 1
.
├── meta-gplv2
├── meta-openembedded
├── meta-qt5
├── meta-renesas
├── meta-renesas-ai
├── meta-rz-features
└── poky
```

#### Initialize build environment ####
```bash
# For hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874:
TEMPLATECONF=$PWD/meta-renesas/meta-rzg2h/docs/template/conf/ source poky/oe-init-build-env build

# For smarc-rzg2l, smarc-rzg2lc, smarc-rzg2ul:
TEMPLATECONF=$PWD/meta-renesas/meta-rzg2l/docs/template/conf/ source poky/oe-init-build-env build

# For smarc-rzv2l:
TEMPLATECONF=$PWD/meta-renesas/meta-rzv2l/docs/template/conf/ source poky/oe-init-build-env build
```

#### Configure bblayers.conf ####
```bash
# All platforms
bitbake-layers add-layer ../meta-qt5
bitbake-layers add-layer ../meta-renesas-ai

# For hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874, smarc-rzg2l, smarc-rzv2l:
bitbake-layers add-layer ../meta-rz-features/meta-rz-codecs
bitbake-layers add-layer ../meta-rz-features/meta-rz-graphics

# For smarc-rzg2lc:
bitbake-layers add-layer ../meta-rz-features/meta-rz-graphics
```

#### Configure local.conf ####
```bash
# Disable CIP Core support (we want to use the latest package versions)
echo 'CIP_MODE = "None"' >> conf/local.conf

# To add ArmNN support
echo 'IMAGE_INSTALL_append = " armnn-dev armnn-examples armnn-tensorflow-lite-dev armnn-onnx-dev armnn-onnx-examples tensorflow-lite-python"' >> conf/local.conf
echo 'IMAGE_INSTALL_append = " tensorflow-lite-staticdev tensorflow-lite-dev tensorflow-lite-benchmark armnn-benchmark"' >> conf/local.conf
echo 'IMAGE_INSTALL_append = " tensorflow-lite-delegate-benchmark"' >> conf/local.conf

# To add ONNX Runtime support
echo 'IMAGE_INSTALL_append = " onnxruntime"' >> conf/local.conf
echo 'IMAGE_INSTALL_append = " onnxruntime-benchmark"' >> conf/local.conf

# To add TensorFlow Lite support
echo 'IMAGE_INSTALL_append = " tensorflow-lite-staticdev tensorflow-lite-dev tensorflow-lite-python"' >> conf/local.conf
echo 'IMAGE_INSTALL_append = " tensorflow-lite-benchmark"' >> conf/local.conf

# To include test scripts
echo 'IMAGE_INSTALL_append = " ai-tests"' >> conf/local.conf
```

### 5) Start Build ###
To build the complete BSP:
```bash
# PLATFORM = hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874, smarc-rzg2l, smarc-rzg2lc, smarc-rzg2ul or smarc-rzv2l
MACHINE=${PLATFORM} bitbake core-image-qt
```

To build the SDK:
```bash
# PLATFORM = hihope-rzg2h, hihope-rzg2m, hihope-rzg2n, ek874, smarc-rzg2l, smarc-rzg2lc, smarc-rzg2ul or smarc-rzv2l
MACHINE=${PLATFORM} bitbake core-image-qt -c populate_sdk
```

### 6) Build Output ###
Once the build is complete, all bootloader, kernel, device tree and filesystem
binaries can be found in the `build/tmp/deploy/images/[machine]/` directory.

License and manifest information can be found in the `build/tmp/deploy/licenses/`
directory.

## Helper Scripts ##
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

### Generate Results Spreadsheet Script ###
The script `gen-benchmark-csv.sh` creates a .csv file that contains the AI benchmark
performance metrics of a provided LAVA job number or log file. 

This script can be used by `submit-lava-job.sh` by setting the options `--gather-benchmarks`
and `--check-results`. It can also be run independently if required.

Run `./scripts/gen-benchmark-csv.sh -h` to get an overview on how to use the script.

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
