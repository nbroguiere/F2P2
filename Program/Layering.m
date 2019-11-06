function [ paths_x, paths_y, height ] = Layering(triangles, n_steps, varargin)
%LAYERING Decomposes a triangular 3D mesh into serial sliced 2D paths. 
%   The triangles are of the form: x1 y1 z1 x2 y2 z2 x3 y3 z3 (cf ReadSTL)
%   The paths_x rows are of the form pathx1 pathx2 pathx3... in a layer
%   Each pathxi is then of the form position1 position2... in a closed loop
%
%   Optional additional arguments:
%   * The error^2 can be added as an additional optional argument:
%   two vertices closer than error will be identified as being the same.
%   * min_z and max_z can be set to restrict the z-range of the slicing.
%   
%   Arguments can be added in the form:
%   Layering(triangular_mesh,n_steps,'min_z', min_z, 'max_z', max_z,
%   'error_sq', error_sq)
%
% Copyright Nicolas Broguiere. First version 2012. Last edit 2019. 

    % Limits (for memory allocation):
    max_number_of_segments=5000;
    max_number_of_paths=500;
    
    % Parse inputs:
    p = inputParser;
    
    triangles_test= @(x) size(x,2)==9;
    
    addRequired(p,'triangles',triangles_test);
    addRequired(p,'n_steps',@isnumeric);
    addOptional(p,'error_sq',nan,@isnumeric);
    addParameter(p,'min_z',nan,@isnumeric);
    addParameter(p,'max_z',nan,@isnumeric);
    
    parse(p,triangles, n_steps, varargin{:});
    
    % Find extrema
    if isnan(p.Results.min_z)
        minima=min(triangles);
        min_z=min([minima(3) minima(6) minima(9)]);
    else
        min_z=p.Results.min_z;
    end
    if isnan(p.Results.max_z)
        maxima=max(triangles);
        max_z=max([maxima(3) maxima(6) maxima(9)]);
    else
        max_z=p.Results.max_z;
    end
    
    % The minimum distance between two points to consider them distinct:
    if isnan(p.Results.error_sq)
        error_sq=1e-24*(max_z-min_z);
    else
        error_sq=p.Results.error_sq;
    end
    
    m=size(triangles,1);
    % Make a loop on the layers and write down the segments of intersection
    % of each triangle. Keep them in two matrices organized by z layer
    % (row) and containing x and y respectively. The segments (two dots
    % each) are one after another. 
    n=n_steps;
    height=max_z-min_z;
    dz=height/n;
    z=min_z+dz/2;
    intersect_x=zeros(n,max_number_of_segments*2)*nan;
    intersect_y=zeros(n,max_number_of_segments*2)*nan;
    intersect_z=zeros(n,max_number_of_segments*2)*nan;
    number_of_segments=zeros(n,1);
    for i=1:n  % Layers loop
        k=1;
        for j=1:m   % Triangles loop
            if any(triangles(j,[3 6 9])>z) && any(triangles(j,[3 6 9])<z)
                if sum(triangles(j,[3 6 9])>z)==2
                    while triangles(j,3)>z
                        triangles(j,:)=[triangles(j,4:9) triangles(j,1:3)];
                    end
                    x=(z-triangles(j,3))/(triangles(j,6)-triangles(j,3));
                    intersect_x(i,k)=triangles(j,1)*(1-x)+triangles(j,4)*x;
                    intersect_y(i,k)=triangles(j,2)*(1-x)+triangles(j,5)*x;
                    intersect_z(i,k)=z;
                    k=k+1;
                    
                    x=(z-triangles(j,3))/(triangles(j,9)-triangles(j,3));
                    intersect_x(i,k)=triangles(j,1)*(1-x)+triangles(j,7)*x;
                    intersect_y(i,k)=triangles(j,2)*(1-x)+triangles(j,8)*x;
                    intersect_z(i,k)=z;
                    k=k+1;
                else
                    while triangles(j,3)<z
                        triangles(j,:)=[triangles(j,4:9) triangles(j,1:3)];
                    end
                    x=(triangles(j,3)-z)/(triangles(j,3)-triangles(j,6));
                    intersect_x(i,k)=triangles(j,1)*(1-x)+triangles(j,4)*x;
                    intersect_y(i,k)=triangles(j,2)*(1-x)+triangles(j,5)*x;
                    intersect_z(i,k)=z;
                    k=k+1;
                    
                    x=(triangles(j,3)-z)/(triangles(j,3)-triangles(j,9));
                    intersect_x(i,k)=triangles(j,1)*(1-x)+triangles(j,7)*x;
                    intersect_y(i,k)=triangles(j,2)*(1-x)+triangles(j,8)*x;
                    intersect_z(i,k)=z;
                    k=k+1;
                end
            end
        end
        number_of_segments(i)=(k-1)/2;
        z=z+dz;
    end
    
    tic
    % Merge points which are closer than the accepted error:
    for i=1:n % layer loop
        j=1;
        % In this loop, put the points that are closer than the error to
        % the exact same value. 
        while(~isnan(intersect_x(i,j))) % segments loop
            k=j+1;
            while(~isnan(intersect_x(i,k))) % secondary segment loop
                if (intersect_x(i,j)-intersect_x(i,k))^2<error_sq % just for the speed
                    if (intersect_x(i,j)-intersect_x(i,k))^2+(intersect_y(i,j)-intersect_y(i,k))^2<error_sq
                        intersect_x(i,k)=intersect_x(i,j);
                        intersect_y(i,k)=intersect_y(i,j);
                    end
                end
                k=k+1;
            end
            j=j+1;
        end
        % In this loop, put the segments that are trivial to NAN:
        j=1;
        while(~isnan(intersect_x(i,j))) % segments loop again
            if intersect_x(i,j)==intersect_x(i,j+1) 
                if intersect_y(i,j)==intersect_y(i,j+1)
                    intersect_x(i,j)=nan;
                    intersect_x(i,j+1)=nan;
                    intersect_y(i,j)=nan;
                    intersect_y(i,j+1)=nan;
                end
            end
            j=j+2;
        end
    end
    
    paths_x=cell(n,max_number_of_paths); % first dimension: layers. second dimension: different paths. Each path: a series of points.
    paths_y=cell(n,max_number_of_paths);
    number_of_paths=zeros(n,1);

    for i=1:n % Layers
        path_number=0;
        while(~all(isnan(intersect_x(i,:)))) % Loop on the different paths, keep on as there are unassigned segments
            path_number=path_number+1;
            path_not_complete=1;
            path_x=zeros(max_number_of_segments,1);
            path_y=zeros(max_number_of_segments,1);
            
            %Find the first segment of a new path
            k=1; % Parsing of the segments
            l=1; % Parsing of the path
            while(isnan(intersect_x(i,k)))
                k=k+1;
            end
            path_x(l)=intersect_x(i,k);
            path_y(l)=intersect_y(i,k);
            intersect_x(i,k)=nan;
            intersect_y(i,k)=nan;
            k=k+1;
            l=l+1;
            path_x(l)=intersect_x(i,k);
            path_y(l)=intersect_y(i,k);
            intersect_x(i,k)=nan;
            intersect_y(i,k)=nan;
            k=k+1;
            l=l+1;
            while(path_not_complete) % Loop to create one path
                if k==2*max_number_of_segments
                    disp 'Achtung ! Volume not closed !';
                    return
                end
                if isnan(intersect_x(i,k))
                    k=k+1;
                elseif (path_x(l-1)-intersect_x(i,k))^2+(path_y(l-1)-intersect_y(i,k))^2<error_sq
                    if(floor(k/2)==k/2)
                        path_x(l)=intersect_x(i,k-1);
                        path_y(l)=intersect_y(i,k-1);
                        intersect_x(i,k)=nan;
                        intersect_y(i,k)=nan;
                        intersect_x(i,k-1)=nan;
                        intersect_y(i,k-1)=nan;
                        k=1;
                        l=l+1;
                    else
                        path_x(l)=intersect_x(i,k+1);
                        path_y(l)=intersect_y(i,k+1);
                        intersect_x(i,k)=nan;
                        intersect_y(i,k)=nan;
                        intersect_x(i,k+1)=nan;
                        intersect_y(i,k+1)=nan;
                        k=1;
                        l=l+1;
                    end
                    if (path_x(l-1)-path_x(1))^2+(path_y(l-1)-path_y(1))^2<error_sq
                        path_not_complete=0;
                    end
                else
                    k=k+1;
                end
            end
            
            path_length=l-1;
            paths_x{i,path_number}=path_x(1:path_length);
            paths_y{i,path_number}=path_y(1:path_length);
        end
        number_of_paths(i)=path_number;
    end
    
    return

end