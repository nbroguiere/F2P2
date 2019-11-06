function [ ] = PlotLayers2D(paths_x, paths_y, varargin)
%PLOTLAYERS2D enables visualization layer by layer of paths matrices.
%
%   The paths_x rows are of the form pathx1 pathx2 pathx3... in a layer
%   Each pathxi is then of the form position1 position2... in a closed loop
%
%   The plots show the directionality of the paths:
%   Red for the beginning of the path, green for the end. Blue the rest. 
%
%   Optional argument: export to disk (0=no, 1=yes)
%
%   Copyright Nicolas Broguiere. First version: 2012. Last update: 2019.
    
    count=1;
    
    p = inputParser;
    addOptional(p,'export',0,@isnumeric);
    parse(p, varargin{:});
    export = p.Results.export;
    
    % Get min and max
    max_x=-inf;
    min_x=+inf;
    max_y=-inf;
    min_y=+inf;
    for i=1:size(paths_x,1)
        for j=1:size(paths_x,2)
            n=size(paths_x{i,j},1);
            if n~=0
                max_xij=max(paths_x{i,j});
                min_xij=min(paths_x{i,j});
                max_yij=max(paths_y{i,j});
                min_yij=min(paths_y{i,j});
                if max_xij>max_x
                    max_x=max_xij;
                end
                if min_xij<min_x
                    min_x=min_xij;
                end
                if max_yij>max_y
                    max_y=max_yij;
                end
                if min_yij<min_y
                    min_y=min_yij;
                end
            end
        end
    end
    
    % Draw the graphs layer by layer 
    if 1    % With shading from red to blue
        figure;
        for i=1:size(paths_x,1)
            hold off;
            for j=1:size(paths_x,2)
                if size(paths_x{i,j},1)~=0
                    plot(paths_x{i,j}(1:2),      paths_y{i,j}(1:2),      'r');
                    hold on;
                    for k=1:length(paths_x{i,j})-1
                        percent=k/length(paths_x{i,j});
                        colork=percent*[1 0 0]+(1-percent)*[0 0 1];
                        plot(paths_x{i,j}(k:k+1),  paths_y{i,j}(k:k+1),  'color', [colork]);
                    end
                end
            end
            h=xlabel('x');ylabel('y');zlabel('z');
            grid on;
            set(h,'fontname','colibri');
            axis([min_x,max_x,min_y,max_y]);
            M(count)=getframe;
            count=count+1;
        end
    else % With red first segment and green last segment
        figure;
        for i=1:size(paths_x,1)
            hold off;
            for j=1:size(paths_x,2)
                if size(paths_x{i,j},1)~=0
                    plot(paths_x{i,j}(1:2),      paths_y{i,j}(1:2),      'r');
                    hold on;
                    plot(paths_x{i,j}(2:end-1),  paths_y{i,j}(2:end-1),  'b');
                    plot(paths_x{i,j}(end-1:end),paths_y{i,j}(end-1:end),'g');
                end
            end
            h=xlabel('x');ylabel('y');zlabel('z');
            grid on;
            set(h,'fontname','colibri');
            axis([min_x,max_x,min_y,max_y]);
            M(count)=getframe;
            count=count+1;
        end
    end
    
    close gcf;
    
    % Export on the harddrive
    if export
        if exist('PlotLayers2D_output.tiff')==2
            delete 'PlotLayers2D_output.tiff'
        end
        for i=1:length(M)
           imwrite(M(i).cdata, 'PlotLayers2D_output.tiff', 'WriteMode','append'); 
        end
    end

    %movie(M,10,5)
    implay(M)

    return

end
