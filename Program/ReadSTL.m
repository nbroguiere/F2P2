function [ triangles, normals, name ] = ReadSTL(name)
% Read an ASCII *.stl file and stores its triangles in a matrix
% Usage: [ triangles, normals, name ] = ReadSTL(name)
% Nicolas Broguiere, first version 3.1.2012, last edit 17.01.2022.

    ID=fopen(name);
    %Import. %f means 'keep the float', and %*s means 'ignore the string'. 
    % Different OS/soft use just \n or \r\n to mark the end of lines. 
    % Since we have no use for lines anyway, just add these characters to delimiters to skip them altogether.
    data=textscan(ID, '%*s %*s %f %f %f %*s %*s %*s %f %f %f %*s %f %f %f %*s %f %f %f %*s %*s','HeaderLines',1,'Delimiter',{' ','\t','\r','\n'},'MultipleDelimsAsOne',1);

    %data{1}=data{1}(1:(end-1));     % Get rid of the last lines, mistaken for values
    %data{2}=data{2}(1:(end-1));
    %data{3}=data{3}(1:(end-1));
    data=cell2mat(data);            % Convert to a proper matrix of numbers from the cell array returned

    normals=data(:,1:3);
    triangles=data(:,4:12);

    fclose(ID);
    
    return

end
