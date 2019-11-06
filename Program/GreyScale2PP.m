function [] = GreyScale2PP(ref_image,template_lrp,pattern_size_xy,min_length_of_path, laser_power, pattern_intensity)
%GREYSCALE2PP Generates an .lrp file with instructions for grey-scale pattern. 
%   *  ref_image is the reference image (8 bit .tif file, one channel). 
%   This image is reproduced as a pattern. 
%   *  template_lrp is the template exported from LAS - Live data mode, the
%   first job in the template defines all the parameters except ROI
%   coordinates and laser power. 
%   * pattern_size_xy is the half width in meters of the physical pattern
%   produced, typically the half width in meters of the field of view.
%   * min_length_of_path indicates the minimum number of nodes in a ROI.
%   Contours with less nodes will be ignored.
%   * laser_power is the series of laser intensities that should be used
%   cumulatively for the patterning process. 
%   * pattern_intensity is the series of resulting intensities, obtained
%   from a calibration curve. For best results, a series of laser power
%   values that results in a nearly linear pattern intensity can be chosen. 
%   
%   Nicolas Broguiere, with contributions from Ines Luchtefeld, 2019

LP = laser_power;
PI = pattern_intensity;

% Open the reference image:
I_bw=imread(ref_image);

% Pad the image:
padsize=1;
I_bw=padarray(I_bw,[padsize padsize]);

% Find the contours: 
threshold_levels=PI*255;
%figure
[C,~]=contour(I_bw,threshold_levels);
axis ij
axis equal

% Extract paths from contour (only for min length of path)
[~,LC]=size(C);
L=0;
C_levels_and_lengths=zeros(2, 0);
C_paths_xy=cell(1,0);
while L<LC
    length_path_m=C(2,L+1);
        if length_path_m>min_length_of_path
            C_levels_and_lengths=[C_levels_and_lengths C(:, L+1)];
            C_paths_xy=[C_paths_xy C(:, (L+2):(L+ 1+ length_path_m))];
        end
    L=L+length_path_m+1;
end

% Close paths & normalize levels & rescale paths
[~,LC_levels_and_lengths]=size(C_levels_and_lengths);
C_paths_xy_closed=cell(1, 0);
C_mat=cell2mat(C_paths_xy);
xy_min=min (C_mat(:));
xy_max=max (C_mat(:));
%size_xy_pattern = size_xy_pattern *0.9;
for n=1:LC_levels_and_lengths
    single_path=C_paths_xy{1,n}; 
    single_path_closed =[single_path single_path(:,1)];
    single_path_rescaled=single_path_closed;
    
    %%%rescaling & centering    
    for m =1:size(single_path_closed, 2)
        point_mx=single_path_closed (1, m);
        point_mx_rescaled=point_mx/(xy_max-xy_min)*2*pattern_size_xy-pattern_size_xy;
        single_path_rescaled(1, m)=point_mx_rescaled; %_rescaled;
        point_my = single_path_closed(2, m);
        point_my_rescaled=point_my/(xy_max-xy_min)*2*pattern_size_xy-pattern_size_xy;
        single_path_rescaled(2, m)=point_my_rescaled; %_rescaled;
    end
    
    C_paths_xy_closed = [C_paths_xy_closed single_path_rescaled];
    C_levels_and_lengths_closed (1, n) = find(threshold_levels==C_levels_and_lengths(1,n));
    C_levels_and_lengths_closed (2, n) = C_levels_and_lengths (2, n)+1 ;
 end

% Orient paths clockwise
C_paths_xy_closed_CW = C_paths_xy_closed;
for n = 1 : LC_levels_and_lengths
    cell_n = C_paths_xy_closed {1,n};
    path_x_n = cell_n (1,:);
    path_y_n = cell_n (2,:);
    [path_x_n_CW, path_y_n_CW] = poly2cw(path_x_n,path_y_n);
    cell_n = [path_x_n_CW ; path_y_n_CW];
    C_paths_xy_closed_CW {1,n} = cell_n;        
end

% Plot paths to check their orientation:
% figure 
% for n = 1 : LC_levels_and_lengths
%     cell_n = C_paths_xy_closed_CW {1,n};
%     x = cell_n (1,:);
%     y = cell_n (2,:);
%     plot(x, y, 'color',rand(1,3))
%     hold on;
% end

% Seperate paths into levels
n_levels = C_levels_and_lengths_closed (1, LC_levels_and_lengths);
C_levels = C_levels_and_lengths_closed (1, :);

num_paths_in_level = histc(C_levels, unique(C_levels));
countdown_levels = num_paths_in_level;

paths_x = cell(n_levels, 0); % first dimension: levels. second dimension: different paths. Each path: a series of points.
paths_y = cell(n_levels, 0);

for p = 1 : LC_levels_and_lengths
    level_p = C_levels (p);
    path_p = C_paths_xy_closed_CW{1,p};
    path_p_T = transpose(path_p);
    for L = 1 : n_levels
        if L == level_p
           num_paths_in_level_p = num_paths_in_level (L);
           countdown_levels (L) = countdown_levels (L) -1;
           count_in_level_p = num_paths_in_level_p - countdown_levels (L);
           
           paths_x {L,count_in_level_p} = path_p_T (:,1);
           paths_y {L,count_in_level_p} = path_p_T (:,2);
        end
    end 
end   

sz = size(paths_x, 2);
paths_x {1, sz+1} = [];
paths_y {1, sz+1} = [];

% Unite paths (without crossing) to workaround the frequent LAS bugs that appear with multiple separate ROIs:
[ paths_x_united, paths_y_united ]=Unite( paths_x, paths_y, pattern_size_xy*1.01);

% Plot united paths as an overlay:
% figure
% for n = 1 : n_levels
%     x = paths_x_united {n, 1};
%     y = paths_y_united {n, 1};
%     plot(x, y, 'color',[1-n/n_levels 0 n/n_levels])
%     axis ij
%     hold on;
% end

% Plot in a layer by layer fashion and save to HD:
% PlotLayers2D(paths_x_united,paths_y_united);

% Convert paths to lrp format
zmin=nan;
zmax=nan;
paths_lrp=Paths_to_lrp_vertices(paths_x_united, paths_y_united);
suffix=strcat(ref_image(1:end-4),"_",num2str(n_levels),"levels");
Paths_to_lrp_file(template_lrp, paths_lrp, zmin, zmax, LP, suffix);
end
