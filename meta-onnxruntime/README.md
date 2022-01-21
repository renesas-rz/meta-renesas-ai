# meta-onnxruntime
ONNX Runtime has an open architecture that is continually evolving to address
the newest developments and challenges in AI and Deep Learning. ONNX Runtime
stays up to date with the ONNX standard, supporting all ONNX releases with
future compatibility and maintaining backwards compatibility with prior
releases.

ONNX Runtime continuously strives to provide top performance for a broad and
growing number of usage scenarios in Machine Learning. Our investments focus on:

1. Run any ONNX model
2. High performance
3. Cross platform

The official website is:  
**https://github.com/microsoft/onnxruntime**

This Yocto/OpenEmbedded meta-layer provides ONNX Runtime support for the Renesas
RZ/G2 and RZ/G2L families of System on Chips.

In order to add ONNX Runtime support to your project, make sure *onnxruntime*
is listed as a dependency to your recipe/package. Listing *onnxruntime-dev*
in *IMAGE\_INSTALL* could be beneficial when you want to populate an SDK for
developing an application based on ONNX Runtime.

After the build is complete a set of C ONNX Runtime libraries
(*libonnxruntime*) will be generated.

The ONNX Runtime C library API can be verified by onnx_test_runner, a program
that loads a set of test cases and runs the self tests.

For more information, please refer to
https://github.com/microsoft/onnxruntime/tree/master/onnxruntime/test/onnx.

This program is installed under */usr/bin/onnxruntime/examples/unittest*.

To use *onnx_test_runner*:  
1. Execute *onnx_test_runner* by running the following commands:
```
cd /usr/bin/onnxruntime/examples/unittest/
./onnx_test_runner ./squeezenet
```
The output of a healthy execution should look like the following:
> result:   
>	Models: 1  
>	Total test cases: 12  
>		Succeeded: 12  
>		Not implemented: 0  
>		Failed: 0  
>	Stats by Operator type:  
>		Not implemented(0):   
>		Failed:  
> Failed Test Cases:  

## Notes ##
**Using Large Models**  
Due to the limited memory size on some platforms, large pre-trained models could
cause out of memory issues. To overcome this memory limitation, a swap file can
used. Please see the top level *README.md* file for details.
