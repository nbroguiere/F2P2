% Free-Form 2-Photon Patterning (F2P2)
% Tutorial: Patterning of complex gradients from an image reference.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Check list %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template definition:
% * Open the Leica application software live data mode. 
% * Define a two-job process. 
% * The first job sets all the parameters for patterning, in particular:
%   - Set the right xy-position in the template, or inactivate xy 
%   positioning in the live data mode load and apply options.
%   - Define a z-stack with the desired positioning.
%   - Activate ROI scan, and draw an arbitrary ROI. Make sure the fs-laser 
%   is off outside the ROI.
%   - Make sure the template does not have autofocus activated.
% 
% Recommended manual double-check: 
% * Make the ROI in the template full-field of view, and manually check the
% maximum xy positions to then manually check the maximum values in the
% generated jobs are within these bounds. 
% * Similarly, check the min/max z-positions in the template and make sure
% the z-positions in the generated file are within these bounds.
% * To manually explore a .lrp template/generated file, either use an xml
% editor, or apply the function "Indentation" in this library to the file 
% and open in a text editor able to handle large text files, e.g. notepad++
%
% Copyright Nicolas Broguiere 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('Program');
addpath('TestData');
clearvars
hold off

pattern_size_xy=3.8E-04; % Half width of the area in the field of view in the template. In meters!! A typical 25x water immersion objective has a field of view of ~500 microns, i.e. 5e-4 m
template_lrp='TestTemplateGradientsSP5.lrp'; 
min_length_of_path=6; % Each mask (grey scale intensity) is then transformed to a path that will become a ROI on the microscope. Paths shorter than this length are removed (aim is to avoid accumulating many paths circulating a single pixel). 
ref_image='TestImage.tif'; % Grayscale image, typically 8 bit single-channel .tif file. 

% Calibration curve input of pattern intensity vs laser power. 
% The exposures will be applied cumulatively, e.g. in this example, 
% the lowest intensity layer will receive one exposure at 8% LP, 
% and the brightest layer will receive 25 exposures at 8-16% LP. 
%
% It is recommended to test various LP progressions in order to find an
% increase rate that produces a linear progression of the pattern
% intensity.

% Calibration curve:
laser_power=8:1/3:16;
pattern_intensity=linspace(1/size(laser_power,2),1,size(laser_power,2));

% Run the script for contour visualization and patterning instructions generation:
GreyScale2PP(ref_image,template_lrp,pattern_size_xy,min_length_of_path, laser_power, pattern_intensity)
