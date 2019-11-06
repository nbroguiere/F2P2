function [ paths_lrp ] = Paths_to_lrp_vertices( paths_x, paths_y )
%PATHS_TO_LRP_VERTICES Converts paths to *.lrp like formatted vertex lists. 
%
% From the cell arrays paths_x and paths_y, describing layer by layer a 3D
% volume, paths2lrp generates a cell array containing the description of
% these contours in the style of Leica *.lrp files. 
%
% Copyright Nicolas Broguiere. First version 2012. Last edit 2019. 

paths_lrp=cell(size(paths_x,1),size(paths_x,2));

n_layers=size(paths_x,1);
for i=1:n_layers
    j=1;
    while(size(paths_x{i,j},1)~=0) % j path under fixing
        
        path_lrp=[];    
        for k=1:size(paths_x{i,j},1)-1
            path_x_str=num2str(paths_x{i,j}(k), 15);
            path_y_str=num2str(paths_y{i,j}(k), 15);
            path_lrp=[path_lrp sprintf('<P X="') path_x_str(1,:) '" Y="' path_y_str(1,:) '"/>'];
        end
        paths_lrp{i,j}=strrep(path_lrp, sprintf('e'), 'E');
        j=j+1;
    end
end
