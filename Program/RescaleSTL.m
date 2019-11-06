function [ triangles_output ] = RescaleSTL(triangles, size_target)
%RESCALESTL_KEEPPROPORTIONS rescales a triangular mesh to fit in a box of
% a given target size, stretching x/y/z to fill the box entirely. 
%
% Inputs:
% * triangles is formatted as the output of ReadSTL. 
% * size_target is a bouding box of the form: [xmin ymin zmin; xmax ymax zmax]
% 
% Copyright Nicolas Broguiere. First version 2012. Last edit 2019. 

    if nargin==2
        min_x_target=size_target(1,1);
        min_y_target=size_target(1,2);
        min_z_target=size_target(1,3);
        max_x_target=size_target(2,1);
        max_y_target=size_target(2,2);
        max_z_target=size_target(2,3);
    else
        min_x_target=0;
        min_y_target=0;
        min_z_target=0;
        max_x_target=1;
        max_y_target=1;
        max_z_target=1;
    end
    
    minima=min(triangles);
    min_x=min([minima(1) minima(4) minima(7)]);
    min_y=min([minima(2) minima(5) minima(8)]);
    min_z=min([minima(3) minima(6) minima(9)]);

    maxima=max(triangles);
    max_x=max([maxima(1) maxima(4) maxima(7)]);
    max_y=max([maxima(2) maxima(5) maxima(8)]);
    max_z=max([maxima(3) maxima(6) maxima(9)]);

    triangles_output=zeros(size(triangles));
    triangles_output(:,[1 4 7])=(triangles(:,[1 4 7])-min_x).*((max_x_target-min_x_target)/(max_x-min_x))+min_x_target;
    triangles_output(:,[2 5 8])=(triangles(:,[2 5 8])-min_y).*((max_y_target-min_y_target)/(max_y-min_y))+min_y_target;
    triangles_output(:,[3 6 9])=(triangles(:,[3 6 9])-min_z).*((max_z_target-min_z_target)/(max_z-min_z))+min_z_target;

    return

end