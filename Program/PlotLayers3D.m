function [ graph ] = PlotLayers3D(paths_x, paths_y, height)
%PLOTLAYERS3D plots the paths in each layer as a contour in a 3D view.
%
%   The paths_x rows are of the form pathx1 pathx2 pathx3... in a layer
%   Each pathxi is then of the form position1 position2... in a closed loop
%
%   Height is the total height of the 3D assembly, assuming the layers
%   described in the paths are equally spaced in z. 
%
% Copyright Nicolas Broguiere. First version 2012. Last edit 2019. 

    if nargin==2
        height=1;
    end
    
    clf;
    hold on;
    
    dz=height/size(paths_x,1);
    
    for i=1:size(paths_x,1)
        for j=1:size(paths_x,2)
            n=size(paths_x{i,j},1);
            if n~=0
                if i/2==floor(i/2)
                    plot3(paths_x{i,j},paths_y{i,j},dz*i*ones(n,1),'b');
                else
                    plot3(paths_x{i,j},paths_y{i,j},dz*i*ones(n,1),'r');
                end
            end
        end
    end
    
    graph=gcf;
    
    return

end
