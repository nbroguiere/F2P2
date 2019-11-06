function [ plot_handle ] = PlotWires(triangles, name)
%PLOTWIRES displays in 3D a triangular mesh from the list of its triangles.
%   The triangles are of the form: x1 y1 z1 x2 y2 z2 x3 y3 z3 (cf ReadSTL)
%
% Copyright Nicolas Broguiere. First version 2012. Last edit 2019. 

    hold off;
    
    % triangles tracing one by one
    for i=1:size(triangles,1)
        plot3([triangles(i,1) triangles(i,4) triangles(i,7) triangles(i,1)], [triangles(i,2) triangles(i,5) triangles(i,8) triangles(i,2)], [triangles(i,3) triangles(i,6) triangles(i,9) triangles(i,3)], 'b', 'linewidth', 1)
        hold on;
    end
    
    % visualisation parameters
    %%%axis([-2.3 2.3 -2.3 2.3 -1 3.6]);
    h=xlabel('x');ylabel('y');zlabel('z');
    grid on;
    set(h,'fontname','colibri');
    if nargin==2
        title(name);
    end
    
    plot_handle = gcf;
    
    return

end