function [ paths_x_fixed, paths_y_fixed ] = FixIntersections( paths_x, paths_y )
%FIXINTERSECTIONS avoids intersections in a series of paths
%
%   ! Work in progress, does not handle all exceptions yet !
%
%   The paths_x rows are of the form pathx1 pathx2 pathx3... in a layer
%   Each pathxi is then of the form position1 position2... in a closed loop
%
% Copyright Nicolas Broguiere. First version 2012. Last edit 2019. 

    %Scan through the paths to fix one by one and uncover them from the
    %rest of the paths from the same layer.
    % i is the layer
    % j is the path under fixing
    % k is the path which it currently has to avoid
    for i=1:size(paths_x,1) % i layer
        j=1;
        while(size(paths_x{i,j},1)~=0) % j path under fixing
            k=j+1;
            while(size(paths_x{i,k},1)~=0) % k path being avoided
                % Scan for intersections between path j and k.
                % See labbook page 58 for calculations.
                % Mark them with type (1 for entering, 2 for leaving).
                % Make lists of the position of these intersections in both
                % paths.
                intersections_type=[];
                intersections_in_j=[];
                intersections_in_k=[];
                intersections_x=[];
                intersections_y=[];
                for l=1:(size(paths_x{i,j},1)-1)
                    for m=1:(size(paths_x{i,k},1)-1)
                        xA=paths_x{i,j}(l);
                        xB=paths_x{i,j}(l+1);
                        xC=paths_x{i,k}(m);
                        xD=paths_x{i,k}(m+1);
                        yA=paths_y{i,j}(l);
                        yB=paths_y{i,j}(l+1);
                        yC=paths_y{i,k}(m);
                        yD=paths_y{i,k}(m+1);
                        tmp=cross([xB-xA yB-yA 0],[xC-xA yC-yA 0]);
                        if tmp(3)>0
                            tmp=cross([xB-xA yB-yA 0],[xD-xA yD-yA 0]);
                            if tmp(3)<0
                                tmp=cross([xD-xA yD-yA 0],[xC-xA yC-yA 0]);
                                if tmp(3)>0
                                    tmp=cross([xD-xB yD-yB 0],[xC-xB yC-yB 0]);
                                    if tmp(3)<0
                                        intersections_type=[intersections_type; 1];
                                        intersections_in_j=[intersections_in_j; l];
                                        intersections_in_k=[intersections_in_k; m];
                                        clear x y;
                                        syms x y;
                                        tmp2=cross([xB-xA yB-yA 0],[x-xA,y-yA,0]);
                                        equ1=[char(tmp2(3)), '=0'];
                                        tmp2=cross([xD-xC yD-yC 0],[x-xC,y-yC,0]);
                                        equ2=[char(tmp2(3)), '=0'];
                                        [solx,soly]=solve(equ1,equ2);
                                        intersections_x=[intersections_x; subs(solx)];
                                        intersections_y=[intersections_y; subs(soly)];
                                    end
                                end
                            end
                        else
                            tmp=cross([xB-xA yB-yA 0],[xD-xA yD-yA 0]);
                            if tmp(3)>0
                                tmp=cross([xD-xA yD-yA 0],[xC-xA yC-yA 0]);
                                if tmp(3)<0
                                    tmp=cross([xD-xB yD-yB 0],[xC-xB yC-yB 0]);
                                    if tmp(3)>0
                                        intersections_type=[intersections_type; 2];
                                        intersections_in_j=[intersections_in_j; l];
                                        intersections_in_k=[intersections_in_k; m];
                                        clear x y;
                                        syms x y;
                                        tmp2=cross([xB-xA yB-yA 0],[x-xA,y-yA,0]);
                                        equ1=[char(tmp2(3)), '=0'];
                                        tmp2=cross([xD-xC yD-yC 0],[x-xC,y-yC,0]);
                                        equ2=[char(tmp2(3)), '=0'];
                                        [solx,soly]=solve(equ1,equ2);
                                        intersections_x=[intersections_x; subs(solx)];
                                        intersections_y=[intersections_y; subs(soly)];
                                    end
                                end
                            end
                        end
                    end
                end
                
                % Recombine the different portions of paths.
                if size(intersections_type,1)~=0
                    tmp_x=[]; % Containing the construction of the path being fixed
                    tmp_y=[]; % Containing the construction of the path being fixed
                    if intersections_type(1)==2 %%original text:=1. I should check the orientation of my paths is always clockwise for this to really work! %   Place an intersection of type 2 (getting out) in first position always.
                        intersections_type=[intersections_type(2:end); intersections_type(1)];
                        intersections_in_j=[intersections_in_j(2:end); intersections_in_j(1)];
                        intersections_in_k=[intersections_in_k(2:end); intersections_in_k(1)];
                        intersections_x=[intersections_x(2:end); intersections_x(1)];
                        intersections_y=[intersections_y(2:end); intersections_y(1)];
                    end
                    intersections_type=[intersections_type; intersections_type(1)]; % Copy the first intersection as being also the last.
                    intersections_in_j=[intersections_in_j; intersections_in_j(1)];
                    intersections_in_k=[intersections_in_k; intersections_in_k(1)];
                    intersections_x=[intersections_x; intersections_x(1)];
                    intersections_y=[intersections_y; intersections_y(1)];
                    for l=1:2:size(intersections_type,1)-2  % Parsing the intersections
                        if intersections_in_j(l)<intersections_in_j(l+1)  % Case no loop problem
                            tmp_x=[tmp_x; intersections_x(l); paths_x{i,j}(intersections_in_j(l)+1:intersections_in_j(l+1))];
                            tmp_y=[tmp_y; intersections_y(l); paths_y{i,j}(intersections_in_j(l)+1:intersections_in_j(l+1))];
                        else % Case there is a loop to fix. 
                            tmp_x=[tmp_x; intersections_x(l); paths_x{i,j}(intersections_in_j(l)+1:end-1); paths_x{i,j}(1:intersections_in_j(l+1))];
                            tmp_y=[tmp_y; intersections_y(l); paths_y{i,j}(intersections_in_j(l)+1:end-1); paths_y{i,j}(1:intersections_in_j(l+1))];
                        end
                        if intersections_in_k(l+1)>=intersections_in_k(l+2) % Paths of opposing directions so path k must be taken backwards. Only true for simple intersections, not for completely trans-section.
                            tmp_x=[tmp_x; intersections_x(l+1); paths_x{i,k}(intersections_in_k(l+1):-1:intersections_in_k(l+2)+1)];
                            tmp_y=[tmp_y; intersections_y(l+1); paths_y{i,k}(intersections_in_k(l+1):-1:intersections_in_k(l+2)+1)];
                        else % Case there is a loop to fix. 
                            tmp_x=[tmp_x; intersections_x(l+1); paths_x{i,k}(intersections_in_k(l+1):-1:1); paths_x{i,k}(end-1:-1:intersections_in_k(l+2))];
                            tmp_y=[tmp_y; intersections_y(l+1); paths_y{i,k}(intersections_in_k(l+1):-1:1); paths_y{i,k}(end-1:-1:intersections_in_k(l+2))];
                        end
                    end
                    paths_x{i,j}=[tmp_x; tmp_x(1)]; % Reassign the fixed path, not forgetting to include the last point. 
                    paths_y{i,j}=[tmp_y; tmp_y(1)];
                end
                
                k=k+1;
            end
            j=j+1;
        end
    end
    
    paths_x_fixed=paths_x;
    paths_y_fixed=paths_y;
    
    return
    
end
