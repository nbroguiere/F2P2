function [ triangles, normals, name] = ReadSTL(name)
%READSTL opens an ASCII stereolithography file into Matlab. 
% * name is the file name as a string. 
% * triangles is a matrix. Each line describes a triangular facet in the
% form: x1 y1 z1 x2 y2 z2 x3 y3 z3
% * normals are in the form xn yn zn
% 
% Copyright Nicolas Broguiere. First version 2012. Last edit 2019. 

    ID=fopen(name);

    textscan(ID, '%*[^\n]', 1);     % Get rid of the first line. 
    data=textscan(ID, '%*s %*s %f %f %f \n %*s %*s \n %*s %f %f %f \n %*s %f %f %f \n %*s %f %f %f \n %*s \n %*s \n');      %Import. %f means 'keep the float', and %*s means 'ignore the string'.
    data{1}=data{1}(1:(end-1));     % Get rid of the last lines, mistaken for values
    data{2}=data{2}(1:(end-1));
    data{3}=data{3}(1:(end-1));
    data=cell2mat(data);            % Convert to a proper matrix of numbers from the cell array returned

    normals=data(:,1:3);
    triangles=data(:,4:12);

    fclose(ID);
    
    return

end