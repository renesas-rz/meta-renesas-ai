# meta-caffe2

Caffe2 is a lightweight, modular, and scalable deep learning framework.
Building on the original Caffe, Caffe2 is designed with expression, speed, and
modularity in mind.

The official website can be found here:  
**https://caffe2.ai/**

This meta-layer provides both libraries and python bindings for Caffe2.

As mentioned in Caffe2 release documentation
(https://github.com/caffe2/caffe2/releases), environment variable *PYTHONPATH*
needs extending for Caffe2 to work properly:  
**export PYTHONPATH=$PYTHONPATH:/usr**

Again, as recommended by Caffe2 documentation
(https://caffe2.ai/docs/getting-started.html?platform=ubuntu), the python
installation can be verified by running the following command:  
**python -c 'from caffe2.python import core' 2>/dev/null && echo "Success" || echo "Failure"**  
If this command prints *Success* the installation was successful.
