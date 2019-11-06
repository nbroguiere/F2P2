function [ paths_x_united, paths_y_united ] = Unite( paths_x, paths_y, xymax )
%UNITE combines all the ROIs in each layer of a pattern in one.  
%   The paths_x rows are layers, of the form pathx1 pathx2 pathx3...
%   Each pathxi is then of the form position1 position2... in a closed loop
%   The output has only one path per layer. 
    
% Copyright Nicolas Broguiere. First version 2012. Last edit 2019. 
    
    if length(xymax)==2
        xmax=xymax(1);
        ymax=xymax(2);
    elseif length(xymax)==1
        xmax=xymax;
        ymax=xymax;
    else
        disp('The length of xymax should be 1 or 2')
        return
    end

    n_layers=size(paths_x,1);
    paths_x_united=cell(n_layers,1);
    paths_y_united=cell(n_layers,1);
    
    offset=0; % Put the connection line on the right out of the screen by this offset. 
    
    for i=1:n_layers
        
        j=1;
        % Matrix receiving the path number, the value and the position of
        % the x-max in columns 1 2 3:
        master=zeros(1,3);
        
        %Find the x max of each path:
        %If several equal max, the first one found is returned. 
        total_length=2;
        while(~isempty(paths_x{i,j}))
            master(j,1)=j;
            [master(j,2), master(j,3)]=max(paths_x{i,j}); 
            j=j+1;
        end
        
        %%%%%%%%% To go around leica bug:
        %Add the left border to guarantee the scale:
        paths_x{i,j}=[-xmax-offset -xmax-offset -xmax-offset]';
        paths_y{i,j}=[ymax -ymax ymax]';
        master(j,:)=[j -xmax-offset 1];
        j=j+1;
        
        %Add the right border as a root:
        paths_x{i,j}=[xmax+offset xmax+offset xmax+offset]';
        paths_y{i,j}=[ymax -ymax ymax]';
        master(j,:)=[j xmax+offset 1];
        
        %Sort the paths from right to left:
        master=sortrows(master,-2);
        n_paths=size(master,1);
        
        % Go through the paths from right to left. Construct a recombined
        % path recursively. 
        
        paths_x_united{i}=paths_x{i,n_paths};
        paths_y_united{i}=paths_y{i,n_paths};
        
        for j1=2:n_paths
            % For the current path, the reconnection point is known. Need
            % to find where to reconnect it on the previous united path:
            current_path=master(j1,1);
            y_r=paths_y{i,current_path}(master(j1,3));
            x_r=xymax+1;
            for k=1:length(paths_y_united{i})-1
                if(paths_y_united{i}(k)<=y_r ...
                        && paths_y_united{i}(k+1)>y_r ...
                        || paths_y_united{i}(k)>=y_r ...
                        && paths_y_united{i}(k+1)<y_r)
                    
                    x_k=paths_x_united{i}(k);
                    x_kp1=paths_x_united{i}(k+1);
                    y_k=paths_y_united{i}(k);
                    y_kp1=paths_y_united{i}(k+1);
                    x_r_tmp=x_k+(y_r-y_k)/(y_kp1-y_k)*(x_kp1-x_k);
                    
                    if x_r_tmp<x_r
                        x_r=x_r_tmp;
                        k_r=k;
                    end
                end
            end
            
            % Now construct the new united path. 
            paths_x_united{i}=[paths_x_united{i}(1:k_r); x_r; paths_x{i,current_path}(master(j1,3):end-1); paths_x{i,current_path}(1:master(j1,3)); x_r;  paths_x_united{i}(k_r+1:end)];
            paths_y_united{i}=[paths_y_united{i}(1:k_r); y_r; paths_y{i,current_path}(master(j1,3):end-1); paths_y{i,current_path}(1:master(j1,3)); y_r;  paths_y_united{i}(k_r+1:end)];
        end
    end
    
    empty_cell=cell(n_layers,1);
    paths_x_united=cat(2, paths_x_united, empty_cell);
    paths_y_united=cat(2, paths_y_united, empty_cell);
end
