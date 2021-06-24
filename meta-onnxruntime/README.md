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
RZ/G1 and RZ/G2 families of System on Chips.

In order to add ONNX Runtime support to your project, make sure *onnxruntime*
is listed as a dependency to your recipe/package. Listing
*onnxruntime-staticdev* and *onnxruntime-dev* in *IMAGE\_INSTALL* could be
beneficial when you want to populate an SDK for developing an application
based on ONNX Runtime.

After the build is complete a set of C ONNX Runtime libraries
(*libonnxruntime*) will be generated.

The ONNX Runtime C library API can be verified by onnx_test_runner, a program
that loads a set of test cases and runs the self tests.

For more information, please refer to
https://github.com/microsoft/onnxruntime/tree/master/onnxruntime/test/onnx.

This program is installed under */usr/bin/onnxruntime/examples/unittest* when
package *onnxruntime-examples* is included.

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

The usage of the C library API can refer to Renesas' image classification sample
application named *onnxruntime_inference_example* which is included in the build
by package *onnxruntime-examples*. The sample application is installed under
*/usr/bin/onnxruntime/examples/inference*.

To use *onnxruntime_inference_example*:  
1. Execute *onnxruntime_inference_example* by running the following commands:
```
cd /usr/bin/onnxruntime/examples/inference/
./onnxruntime_inference_example
```

This example code loads the pre-installed ONNX MobileNet v2 1.0 224 model
(mobilenetv2-1.0.onnx) from */usr/bin/onnxruntime/examples/inference* and uses
the pre-installed image grace_hopper_224_224.jpg from
*/usr/bin/onnxruntime/examples/images*.

The output of a healthy execution should look like the following:
> Number of inputs = 1  
> Input 0 : name=data  
> Input 0 : type=1  
> Input 0 : num_dims=4  
> Input 0 : dim 0=1  
> Input 0 : dim 1=3  
> Input 0 : dim 2=224  
> Input 0 : dim 3=224  
> index [652]: military uniform uniform :prob [11.092553]  
> index [834]: suit, suit of clothes clothes :prob [10.013694]  
> index [906]: Windsor tie tie :prob [9.893828]  
> index [451]: bolo tie, bolo, bola tie, bola bola :prob [9.001971]  
> index [743]: prison, prison house house :prob [8.869608]  
> index [465]: bulletproof vest vest :prob [8.603733]  
> Done!  

## Notes ##
**Using Large Models**  
Due to the limited memory size on some platforms, large pre-trained models could
cause out of memory issues. To overcome this memory limitation, a swap file can
used. Please see the top level *README.md* file for details.
