function [ n_layers, zmin, zmax ] = compute_n_layers(triangles, step)
%COMPUTE_N_LAYERS computes the number of layers necessary in the slicing given a scaled
% triangular mesh and a desired step size. 
%
% Copyright Nicolas Broguiere. First version: 2012. Last edit: 2019

zmin=min(min(triangles(:,[3,6,9])));
    zmax=max(max(triangles(:,[3,6,9])));
    n_layers=ceil((zmax-zmin)/step);
end

