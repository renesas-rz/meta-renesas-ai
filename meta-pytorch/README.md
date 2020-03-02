# meta-pytorch

PyTorch is a Python package that provides two high-level features:
- Tensor computation (like NumPy) with strong GPU acceleration
- Deep neural networks built on a tape-based autograd system

The official website is:
**https://pytorch.org/**

This Yocto/OpenEmbedded meta-layer provides PyTorch support for the RZ/G1 and
RZ/G2 families of System on Chips.

In order to add PyTorch support to your project, make sure `pytorch` is
listed as a dependency to your recipe/package. This can be done by adding
`IMAGE_INSTALL_append = " pytorch"` to the `local.conf`

The PyTorch library can be verified by running the following command in the
terminal: `python -c "import torch; print(torch.__version__)"`

*meta-pytorch* also includes a recipe for TorchVision, a library useful for
vision-based machine learning. TorchVision support can be added to your project
by adding `IMAGE_INSTALL_append = " torchvision"` to the `local.conf`.

## Additional Model Support

In order to add support for Inception v3 and GoogLeNet models within
TorchVision, Scipy must be added to your project.

### For RZ/G1 devices:

 - Uncomment the following line in the `local.conf`:
```
#require ${META_PYTORCH_DIR}/recipes-devtools/python/python-scipy/python-scipy_RZ-G1.conf
```

### For RZ/G2 devices:

 - Uncomment the following line in the `local.conf`:
```
#require ${META_PYTORCH_DIR}/recipes-devtools/python/python-scipy/python-scipy_RZ-G2.conf
```
 - Comment the following line in the `local.conf`:
```
INCOMPATIBLE_LICENSE = "GPLv3 GPLv3+"
```
This will enable GPLv3 licensed software, please make sure you fully understand
the implications of enabling license GPLv3 by reading the relevant documents
(e.g. https://www.gnu.org/licenses/gpl-3.0.en.html).
