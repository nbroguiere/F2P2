function [ plot_handle ] = PlotDots(triangles, normals, name)
%PLOTDOTS enables visualization of the nodes of a mesh open with ReadSTL. 
% Takes as an input the output from ReadSTL. Or can be used directly on a
% list of triangles of the form x1,y1,z1, x2,y2,z2, x3,y3,z3 on each line.
%
% Copyright Nicolas Broguiere. First version 2012. Last edit 2019. 

    hold off;
    scatter3(triangles(:,1), triangles(:,2), triangles(:,3), 'r', '.');
    hold on;
    %scatter3(triangles(:,4), triangles(:,5), triangles(:,6), 'g', '.');
    %scatter3(triangles(:,7), triangles(:,8), triangles(:,9), 'b', '.');
    
    % visualisation parameters
    %%%axis([-2.3 2.3 -2.3 2.3 -1 3.6]);
    h=xlabel('x');ylabel('y');zlabel('z');
    grid on;
    set(h,'fontname','colibri');
    if nargin==3
        title(name);
    end
    
    plot_handle = gcf;
    
    return

end