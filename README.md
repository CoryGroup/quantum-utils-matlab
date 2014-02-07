Quantum Utils for MATLAB
========================

This is the README file for the MATLAB version of the quantum-utils 
library. This library includes MATLAB classes and functions which are 
related to quantum information computation.

Installation
------------

1. In MATLAB, navigate the current directory to your quantum-utils-matlab
folder (GUI: use the "current folder" dialogue on the left hand side; 
command line: cd /path/to/quantum-utils/matlab).

2. Run the ``install.m`` file (ie just type ``install`` and press enter). If
your installation of MATLAB is on a protected portion of your hard disk, you
will need the root/administrative password. All ``install.m`` does is add 
the complete path of your quantum-utils-matlab/src folder to its
permanent list of known MATLAB paths, such that you won't need to add
the path everytime you start up matlab. You can verify that the 
installation was correct by typing ``path`` and checking that the 
``quantum-utils-matlab/src`` folder is present.

Documentation
-------------

All MATLAB code in this library should be self-documenting. This means 
that the documentation for a particular function or class will be right
in the matlab file itself. Now, when you type, for example,

    >> doc ptrace

a window should pop up with a description of what the ``ptrace`` function does,
and perhaps an example or two as well.

To see how to do this when you add your own files, compare, for example,
the output of ``doc ptrace`` with the ptrace.m file. You just have to put
your comments in the right spot. Similar for classes.

