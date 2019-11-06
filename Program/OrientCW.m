function [ paths_x_fixed, paths_y_fixed ] = OrientCW( paths_x, paths_y )
%ORIENTCW orients the given paths clockwise.
%   The paths_x rows are of the form pathx1 pathx2 pathx3... in a layer
%   Each pathxi is then of the form position1 position2... in a closed loop
%   
%   Algorithm description: 
%   Find the bounding box of each path. 
%   Each path has to intersect one of the two diagonals of its bounding box.
%   Find these points of intersection. The direction of crossing of the
%   most outer point gives the direction of the path. Then flip it if this
%   is not clockwise. 
%   
%   Copyright Nicolas Broguiere 2012 last edit 2019
    
    %Scan through the paths to fix one by one
    % i is the layer
    % j is the path under fixing
    counter_clockwise=0;
    counter_trigo=0;
    for i=1:size(paths_x,1) % i layer
        j=1;
        while(size(paths_x{i,j},1)~=0) % j path under fixing
            % Scan for intersections between path j and a lign.
            % Mark them with type (1 for entering, 2 for leaving).
            % Make lists of the position of these intersections in both paths.
            intersections_type=[];
            intersections_in_j=[];
            intersections_x=[];
            intersections_y=[];
            % Check intersection with the first diagonal
            intersecting_diagonal=1;
            for l=1:(size(paths_x{i,j},1)-1)
                xA=paths_x{i,j}(l);
                xB=paths_x{i,j}(l+1);
                xC=min(paths_x{i,j});
                xD=max(paths_x{i,j});
                yA=paths_y{i,j}(l);
                yB=paths_y{i,j}(l+1);
                yC=min(paths_y{i,j});
                yD=max(paths_y{i,j});
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
                                % Slow version easy to read:
                                % clear x y;
                                % syms x y;
                                % tmp2=cross([xA-xB yA-yB 0],[x-xA,y-yA,0]);
                                % equ1=[char(tmp2(3)), '==0'];
                                % tmp2=cross([xC-xD yC-yD 0],[x-xC,y-yC,0]);
                                % equ2=[char(tmp2(3)), '==0'];
                                % [solx,soly]=solve(str2sym(equ1),str2sym(equ2));
                                % intersections_x=[intersections_x; subs(solx)];
                                % intersections_y=[intersections_y; subs(soly)];
                                % Fast version harder to read:
                                soly=((xA-xC)*(yA-yB)*(yC-yD)+yC*(xC-xD)*(yA-yB)-yA*(xA-xB)*(yC-yD))/(xC-xD)*(yA-yB)-(xA-xB)*(yC-yD);
                                solx=xA+(xA-xB)*(soly-yA)/(yA-yB);
                                intersections_x=[intersections_x; solx];
                                intersections_y=[intersections_y; soly];
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
                                soly=((xA-xC)*(yA-yB)*(yC-yD)+yC*(xC-xD)*(yA-yB)-yA*(xA-xB)*(yC-yD))/(xC-xD)*(yA-yB)-(xA-xB)*(yC-yD);
                                solx=xA+(xA-xB)*(soly-yA)/(yA-yB);
                                intersections_x=[intersections_x; solx];
                                intersections_y=[intersections_y; soly];
                            end
                        end
                    end
                end
            end
            
            if size(intersections_x,1)==0
                intersecting_diagonal=2;
                for l=1:(size(paths_x{i,j},1)-1)
                    xA=paths_x{i,j}(l);
                    xB=paths_x{i,j}(l+1);
                    xC=min(paths_x{i,j});
                    xD=max(paths_x{i,j});
                    yA=paths_y{i,j}(l);
                    yB=paths_y{i,j}(l+1);
                    yC=max(paths_y{i,j});
                    yD=min(paths_y{i,j});
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
                                    soly=((xA-xC)*(yA-yB)*(yC-yD)+yC*(xC-xD)*(yA-yB)-yA*(xA-xB)*(yC-yD))/(xC-xD)*(yA-yB)-(xA-xB)*(yC-yD);
                                    solx=xA+(xA-xB)*(soly-yA)/(yA-yB);
                                    intersections_x=[intersections_x; solx];
                                    intersections_y=[intersections_y; soly];

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
                                    soly=((xA-xC)*(yA-yB)*(yC-yD)+yC*(xC-xD)*(yA-yB)-yA*(xA-xB)*(yC-yD))/(xC-xD)*(yA-yB)-(xA-xB)*(yC-yD);
                                    solx=xA+(xA-xB)*(soly-yA)/(yA-yB);
                                    intersections_x=[intersections_x; solx];
                                    intersections_y=[intersections_y; soly];
                                end
                            end
                        end
                    end
                end
            end
            
            % Sort the intersections from the left (xmin) to the right
            % (xmax) to find which one is the first intersection with the
            % diagonal segment under study.
            intersections=[intersections_type, intersections_x];
            intersections=sortrows(intersections, 2);
            
            % Then just check the type of the first intersection.
            % If it's not entering but getting out: means the path is not
            % oriented right. 
            if intersections(1,1)==2
                paths_x{i,j}=flipud(paths_x{i,j});
                paths_y{i,j}=flipud(paths_y{i,j});
                counter_trigo=counter_trigo+1;
            elseif intersections(1,1)==1
                counter_clockwise=counter_clockwise+1;
            else
                disp("error: intersection type not recognized")
            end
            
            j=j+1;
        end
    end
    
    disp(strcat("number of clockwise contours found: ",num2str(counter_clockwise)))
    disp(strcat("number of counter-clockwise contours found: ",num2str(counter_trigo)))
    
    paths_x_fixed=paths_x;
    paths_y_fixed=paths_y;
    
    return
    
end
