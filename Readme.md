# Overview
Matlab library that takes inputs in the form of gray scale images (free-contrast) or triangular meshes (free-form) and generates instructions for their reproduction in two-photon patterning experiments. 

A Leica Application Software (LAS) Live data mode file (.lrp) is used as a template setting basic parameters, and another .lrp file is generated that contains the complex patterning instructions. 

# Software
Matlab 2018b with:
	- Image Processing toolbox
	- Mapping toolbox

# Quick-start
Download the F2P2 library, and open one of the tutorials in Matlab to run the whole workflow on a test 3D model or image. The flow can then be adapted to use other template images, dimensions, or inputs to patterns. 

Minor modifications in the .lrp file generation function can be needed when using the library on a system that has not been tested before. 

#Copyright 
(C) 2019 Nicolas Broguiere
GreyScale patterning function includes code by Ines Luchtefeld. 

This library helps to generate instructions for Leica two-photon microscopes, but it is not developed nor supported by Leica. We recommend great care in usage to avoid physical damage to instruments that would not necessarily be covered by any warranty. 

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

The complete license information is found in License_GPL3.txt
