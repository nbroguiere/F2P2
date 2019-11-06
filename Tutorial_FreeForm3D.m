% Free-Form 2-Photon Patterning (F2P2)
% Tutorial: Patterning of a 3D shape from a triangular mesh reference.
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
%   is off outside the ROI and at the desired power inside the ROI.
%   - Make sure the template does not have autofocus activated.
% 
% Recommended manual double-check: 
% * Make the ROI in the template full-field of view, and manually check the
% maximum xy positions to then manually check the maximum values in the
% generated jobs are within these bounds. 
% * Similarly, check the min/max z-positions in the template and make sure
% the z-positions in the generated file are within these bounds.
% * Check if the 
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

% Indicate the limits and the .lrp template: 
xmax=2.3E-04;  % In meters !! Half size of the field of view. 
ymax=xmax;
zmin=-200e-6;  % In meters! Careful with system limits (or would lead to stage out of range, or objective crashing into stage).
zmax=200e-6;   % In meters! Careful with system limits (or would lead to stage out of range, or objective crashing into stage).
step=1e-6;     % In meters!

template_lrp='TestTemplate3DshapeSP8.lrp'; 
stl_model='Test3Dshape.stl';  % ASCII .stl, meshlab is a good open-source option to convert from binary .stl. Blender good open-source 3D edition. 

% *.lrp template should provide the exact uncaging settings!
% Typically include two jobs: the first one with a ROI scan giving the
% bleaching settings. The second can be anything.

% Notes that when exploring the .lrp file manually, z-position refers to 
% the "wide" objective, additional z-positions to the piezo stage. 
% Be careful about the piezo-stage settings: I usually use it in restricted
% range, which means it has a movement range of -250 to +250 10^-6 meters. 

% Load a new 3D model:
triangles=ReadSTL(stl_model);

% (optional) Check the 3D model: 
PlotWires(triangles);
PlotDots(triangles);

% Rescale the mesh so that it has coordinates in meters fitting within the user defined patterning area: 
triangles=RescaleSTL_KeepProportions(triangles,[-xmax -ymax zmin; xmax ymax zmax]);

% Compute the number of layers needed given a user step size, and their min and max position after the scaling has been done: 
[n_layers, zmin2, zmax2]=compute_n_layers(triangles, step); 

% Do the slicing of the 3D mesh into a series of 2D ROIs, for each layer: 
[paths_x, paths_y, height]=Layering(triangles,n_layers);

% Check in 3D the overall shape defined by these ROIs: 
PlotLayers3D(paths_x,paths_y,height);

% (optional) Not usually needed, but option to orient all the paths clockwise for clarity:
[paths_x, paths_y]=OrientCW(paths_x,paths_y);
%%%FixIntersections(paths_x,paths_y) % Mesh repair: in development, not recommended at the moment. Not needed if using clean input meshes anyway.

% (optional) Check the ROIs and their orientation layer by layer (also writes down PlotLayers2D_output on the hardrive if adding an argument =1):
PlotLayers2D(paths_x,paths_y);

% Unite all the ROIs in each layer into a single ROI with zero-thickness
% lines in between subparts. Needed to overcome a LAS bug when handling
% many ROIs.
[paths_x, paths_y]=Unite(paths_x,paths_y,[xmax,ymax]);

% Convert the paths as Matlab objects to paths in LAS Live data mode like formatting:
paths_lrp=Paths_to_lrp_vertices(paths_x, paths_y);

% Generate a new *.lrp file:
suffix=[stl_model(1:end-4) '_' num2str(n_layers) '_layers'];
LP=nan; % Laser power to nan means it is kept from the template.
Paths_to_lrp_file(template_lrp, paths_lrp, zmin2, zmax2, LP, suffix);
