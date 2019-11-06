function [] = Paths_to_lrp_file(template_lrp, paths_lrp, zmin, zmax, LP, suffix)
%PATHS_TO_LRP_LP Writes the layers for the patterning described in paths_lrp in a .lrp file using the parameters in template_lrp. 
%
% The first block of the template .lrp file will replicated for each paths_lrp 'layer', except: 
%       - the ROI will be updated to correspond to the path described in paths_lrp
%       - the zposition will be updated to go linearly from zmin to zmax.
%           ( if the template is not using the zposition, for example if it's a
%           stack, then this has no influence). If zmin or zmax are set to
%           nan, then the zpositions in the template won't be edited at
%           all.
%       - the laser power is set to LP (if a single number, kept the same,
%           if it is a list of the size of paths_lrp, it is updated for
%           each path set. If the laser power is set to nan, then it won't
%           be edited at all from the template. 
%
% Finally, a new .lrp file will be created. It will be named using the name 
% of the template concatenated with the suffix given as last argument. 
%
% Before running, most important is to check the Zposition, to ensure the values are correct
% and will not cause the objective to crash into the sample! Particularly
% when working on a microscope without piezo-stage. 
%
% Important when extending the script for new Leica MP systems:
% This function needs to know about the attenuator wheel used for MP laser
% intensity tuning. These wheels are defined as: Wheel Qualifier="214"
% The FilterSpectrumValue is indicative (number to display), the
% FilterSpectrumPos is what really sets the laser power delivered. 
% The wheel position vs laser power is different from one machine to the
% other, and machines with several MP lasers can have several wheels. Users
% need to adapt the scripts to their machine if it differs significantly from 
% the machines already supported by locating which wheel should be 
% controlled to set the LP for 2PP, and getting a calibration curve of 
% laser power vs wheel position (see examples line 58-64).
%
% A new slot of wheel position calibration curve can be added using the
% header of the .stl file as a reference, and then one can fill in the 
% wheel positions vs laser power under the "wheel_position" variable. 
%
% Copyright Nicolas Broguiere. First version 2012. Last edit 2019. 

% Open the template and show the name of the output file
output_name=strcat(template_lrp(1:end-4),'+',suffix,'.',template_lrp(end-2:end));
disp(output_name);
script_in=fileread(template_lrp);

% Clean up the input file
script_in=strrep(script_in, sprintf('\t'), '');
script_in=strrep(script_in, char(13), sprintf(''));
script_in=strrep(script_in, sprintf('\n'), '');
script_in=regexprep(script_in,'>[ ]*<','><');

% Read the version of the Leica software:
LeicaVersion="NULL";
header=script_in(1:1000);
string1='<!--Leica Application Suite X (LAS X)-->';
string2='<!--Leica Application Suite Advanced Fluorescence Software (LAS-AF)-->';
if contains(header, string1), LeicaVersion="SP8"; end
if contains(header, string2), LeicaVersion="SP5"; end

% On the currently supported machines (EPFL SP5-MP upright, ETHZ SP8-MP inverted), the wheel positions vs laser power are:
if LeicaVersion=="SP8"
    LP_for_wheel=  [0       1       2       5       10      25      50      75      80      90      100   ]';
    wheel_position=[-21999  -12689  -8810   -1038   7906    26667   51000   75333   80906   94094   124000]';
elseif LeicaVersion=="SP5"
    LP_for_wheel=  [0       1       2       5       10      25      50      75      80      90      100   ]';
    wheel_position=[-21999  -12689  -8810   -1038   7906    26667   51000   75333   80906   94094   124000]';
else
    error("This version of the Leica software is not yet supported.");
    return
end

if length(LP)==1
    LP=repmat(LP,size(paths_lrp,1),1);
end

% Find the position of the block list:
string1='<LDM_Block_Sequence_Element_List>';
position1=strfind(script_in, string1);

% Everything before this block list is kept as is in the output:
position1=position1(1)+size(string1,2);
script_out=script_in(1:position1-1);

% Find the position of the end of the first block:
string2='/>';
position2=strfind(script_in(position1:position1+2000),string2);
position2=position2(1)+size(string2,2)+position1-1;

% Generate one block in the output per layer/mask in the pattern
n_blocks=size(paths_lrp,1);
block=script_in(position1:position2-1);
for i=1:n_blocks
    block=regexprep(block,'BlockID="\d*"',['BlockID="' num2str(i) '"']);
    block=regexprep(block,'ElementID="\d*"',['ElementID="' num2str(i) '"']);
    script_out=[script_out block];
end

% Mark the end of the sequence section and the beginning of the block list
script_out=[script_out '</LDM_Block_Sequence_Element_List><LDM_Block_Sequence_Block_List>'];

% Find the beginning of the first block:
string1='<LDM_Block_Sequence_Block BlockType="0"';
position1=strfind(script_in, string1);
position1=position1(1);

% Find the end of the first block:
string2='</LDM_Block_Sequence_Block>';
position2=strfind(script_in, string2);
position2=position2(1)+size(string2,2);

%Write the blocks. One block is needed for each contour in paths_lrp. 
n_blocks=size(paths_lrp,1);
block=script_in(position1:position2-1);

% Make a few checks that the miscroscope is properly setup:
if LeicaVersion=="SP8"
    if ~contains(block,'SuperZModeName="RestrictedRange" ZMode="1" ZUseModeName="z-galvo"')
        error("Error: set LAS to use the piezo stage, and in restricted range, and start over again.")
        return
    end
elseif LeicaVersion=="SP5"
    if ~contains(block,'ZUseMode="2" ZPosition=') && ~isnan(zmin*zmax)
        error("Error: set LAS to use the objective movement (so called wide) rather than piezo stage, and start over again")
        return
    end
end

for i=1:n_blocks
    % Number of the block: 
    block=regexprep(block,'BlockType="0" BlockID="\d*"',['BlockType="0" BlockID="' num2str(i) '"']);

    % On SP8, ROIs have unique IDs, they are not really used currently but to be on the safe side give unique IDs in the appropriate format:
    if LeicaVersion=="SP8"
        block=regexprep(block,'Name="BleachPointROISet" UniqueID="[a-z0-9-]*"',['Name="BleachPointROISet" UniqueID="' num2str(10000+i) 'cc4-192a-11e2-bcf3-eccd6d215747"']);
        block=regexprep(block,'Name="DCROISet" UniqueID="[a-z0-9-]*"',['Name="DCROISet" UniqueID="' num2str(20000+i) 'cc4-192a-11e2-bcf3-eccd6d215747"']);
    end
    
    % Set the Zposition in our jobs (if zmin and zmax are not nan):
    if ~isnan(zmin*zmax)
        if LeicaVersion=="SP8" % Using the piezo stage. Make sure it is in restricted mode.
            block=regexprep(block,'ZPosition="[0-9-E.]*" IsSuperZ="0"',['ZPosition="' strrep(num2str(zmin+(i-1)/(n_blocks-1)*(zmax-zmin),15), 'e', 'E') '" IsSuperZ="0"']);
            block=regexprep(block,'SuperZModeName="RestrictedRange" ZMode="1" ZUseModeName="z-galvo" ZPosition="[0-9-E.]*"',['SuperZModeName="RestrictedRange" ZMode="1" ZUseModeName="z-galvo" ZPosition="' strrep(num2str(zmin+(i-1)/(n_blocks-1)*(zmax-zmin),15), 'e', 'E') '"']);
        elseif LeicaVersion=="SP5"
            block=regexprep(block,'ZUseMode="2" ZPosition="[0-9-E.]*" IsSuperZ="0"',['ZUseMode="2" ZPosition="' strrep(num2str(zmin+(i-1)/(n_blocks-1)*(zmax-zmin),15), 'e', 'E') '" IsSuperZ="0"']);
            block=regexprep(block,'<AdditionalZPosition Valid="1" SuperZMode="1" ZMode="2" ZPosition="[0-9-E.]*"',['<AdditionalZPosition Valid="1" SuperZMode="1" ZMode="2" ZPosition="' strrep(num2str(zmin+(i-1)/(n_blocks-1)*(zmax-zmin),15), 'e', 'E') '"']);
        end
    end
    % The filter(s) with qualifier 214 is/are the one(s) controlling the MP laser(s) attenuation: 
    if ~isnan(LP)
        if LeicaVersion=="SP8"
            block=regexprep(block,'<Wheel Version="0" Qualifier="214" FilterWheelName="Attenuation MP" LightSourceType="3" LightSourceName="MP" FilterIndex="0" FilterName="Min" IsSpectrumTurnMode="1" FilterSpectrumPos="([0-9-E.]*)" FilterSpectrumValue="[0-9-E.]*"',['<Wheel Version="0" Qualifier="214" FilterWheelName="Attenuation MP" LightSourceType="3" LightSourceName="MP" FilterIndex="0" FilterName="Min" IsSpectrumTurnMode="1" FilterSpectrumPos="' num2str(floor(interp1q(LP_for_wheel,wheel_position,LP(i)))) '" FilterSpectrumValue="' num2str(LP(i)) '"']);
        elseif LeicaVersion=="SP5"
            block=regexprep(block,'<Wheel Qualifier="214" FilterIndex="0" IsSpectrumTurnMode="1" FilterSpectrumPos="([0-9-E.]*)" FilterSpectrumValue="[0-9-E.]*"',['<Wheel Qualifier="214" FilterIndex="0" IsSpectrumTurnMode="1" FilterSpectrumPos="' num2str(floor(interp1q(LP_for_wheel,wheel_position,LP(i)))) '" FilterSpectrumValue="' num2str(LP(i)) '"']);
        end
    end
    
    % Find the ROI definition in the block and copy it for edition
    position1=strfind(block,'<ROI>');
    position2=strfind(block,'</ROI>');
    position1=position1(1);
    position2=position2(1)+size('</ROI>',2);
    ROIs_in=block(position1:position2-1);
    
    % Don't change it until the children part
    position3=strfind(ROIs_in,'<Children>');
    if isempty(position3)
        error('There is no ROI in the first job of the template! Cancelling lrp file generation.')
    end
    position3=position3(1)+size('<Children>',2);
    ROIs_out=ROIs_in(1:position3-1);
    
    % Then take the first child (first ROI in the template) as a template to write down our paths. 
    child1=strfind(ROIs_in,'<Vertices>');
    child1=child1(1)+size('<Vertices>',2);
    child2=strfind(ROIs_in,'</Transformation>');
    child2=child2(1);
    child3=strfind(ROIs_in,'</Element>');
    child3=child3(1)+size('</Element>',2);
    j=1;
    while(size(paths_lrp{i,j},2)~=0)
        if LeicaVersion=="SP8"
            part1=regexprep(ROIs_in(position3:child1-1),'<Element Name="[a-zA-Z0-9-._ ]*" UniqueID="[a-z0-9-]*">',['<Element Name="ROI.' sprintf('%03.0f',j) '" UniqueID="' num2str(10000000+i+1000*j) '-192b-11e2-bcf3-eccd6d215747">']);
        else
            part1=regexprep(ROIs_in(position3:child1-1),'<Element Name="[a-zA-Z0-9-._ ]*"',['<Element Name="ROI' num2str(j) '"']);
        end
        part2='</Vertices><Transformation Rotation="0"><Scaling XScale="1" YScale="1"/><Translation X="0" Y="0"/>';
        part3=ROIs_in(child2:child3-1);
        ROIs_out=[ROIs_out part1 paths_lrp{i,j} part2 part3];
        j=j+1;
    end
    
    % After the children, just don't change the rest of the ROI part.
    ROIs_out=[ROIs_out '</Children></Element></LMSDataContainerHeader></ROI>'];
    
    % Finally reinsert the children in the main ROI container, and the block in the script:
    %block=[block(1:position1-1) ROIs_out block(position2:end)];
    %script_out=[script_out block];
    script_out=[script_out block(1:position1-1) ROIs_out block(position2:end)];
end

% Mark the end of the list.
script_out=[script_out '</LDM_Block_Sequence_Block_List></LDM_Block_Sequence></Configuration>'];

% Actually not needed, giving unique tags to the memory blocks.
% if LeicaVersion=="SP8"
%     [memblocks_start, memblocks_end]=regexp(script_out,'<Memory Size="0" MemoryBlockID="MemBlock_\d*"/>','start','end');
%     for i=1:size(memblocks_start,2)
%         script_out(memblocks_start(i):memblocks_end(i))=['<Memory Size="0" MemoryBlockID="MemBlock_' sprintf(['%04.0f'],1000+i) '"/>'];
%     end
% elseif LeicaVersion=="SP5"
%     [memblocks_start, memblocks_end]=regexp(script_out,'<Memory Size="0" MemoryBlockID="MemBlock_\d*"/>','start','end');
%     for i=1:size(memblocks_start,2)
%         if size(script_out(memblocks_start(i):memblocks_end(i)),2)==46
%             script_out(memblocks_start(i):memblocks_end(i))=['<Memory Size="0" MemoryBlockID="MemBlock_' sprintf(['%02.0f'],i) '"/>'];
%         elseif size(script_out(memblocks_start(i):memblocks_end(i)),2)==47
%             script_out(memblocks_start(i):memblocks_end(i))=['<Memory Size="0" MemoryBlockID="MemBlock_' sprintf(['%03.0f'],i) '"/>'];
%         end
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Then fix the indentation %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% NEW LINES %%%%%%%%%%%%%

script_out=strrep(script_out, '>', '>\n');

%%%%%%%%%%% TABULATIONS %%%%%%%%%%%%

tmp=strfind(script_out(1:300), '<Configuration');
headings=script_out(1:tmp-1);
script_out=script_out(tmp:end);

newlines=strfind(script_out, '>');
n=size(newlines,2);

% Everything calibrated to give the position of the bracket.
open2=strfind(script_out,'</');     %1
open2=[open2;ones(1,size(open2,2))];
close2=strfind(script_out,'/>')+1;  %2
close2=[close2;2*ones(1,size(close2,2))];
open=strfind(script_out,'<');       %3
open=[open;3*ones(1,size(open,2))];
close=strfind(script_out,'>');      %4
close=[close;4*ones(1,size(close,2))];

% First column contains positions, second column contains type of bracket.
brackets=[open, open2, close, close2]';
brackets=sortrows(brackets,[1,2]);
% Suppress double detection still.
n=size(brackets,1);
for i=1:(n-1)
    if brackets(i,1)==brackets(i+1,1)
        brackets(i+1,2)=0;
    end
end

%Indentation j:
j=0;
k=0;
counter=0;
for i=1:n
    bracket_type=brackets(n-i+1,2);
    if bracket_type==3 && k==0
        j=j-1;
    end
    if bracket_type==1 || bracket_type==3
        counter=counter+j;
        % Previous version was directly (and with no next loop):
        % script_out=[script_out(1:brackets(n-i+1,1)-1) blanks(j) script_out(brackets(n-i+1,1):size(script_out,2))];
    end
    if bracket_type==1
        j=j+1;
    end
    if bracket_type==2
        k=1;
    end
    if bracket_type==4
        k=0;
    end
end

script_out2=blanks(counter+size(script_out,2));

%Indentation j:
j=0; %normal is 0!
k=0;
last_bracket=size(script_out2,2)-counter+1;
sum_j=0;
for i=1:n
    bracket_type=brackets(n-i+1,2);
    if bracket_type==3 && k==0
        j=j-1;
    end
    if bracket_type==1 || bracket_type==3
         if j>=0
            script_out2(brackets(n-i+1,1)+counter-sum_j:last_bracket+counter-sum_j-1)=script_out(brackets(n-i+1,1):last_bracket-1);
            last_bracket=brackets(n-i+1,1);
            sum_j=sum_j+j;
         end
    end
    if bracket_type==1
        j=j+1;
    end
    if bracket_type==2
        k=1;
    end
    if bracket_type==4
        k=0;
    end
end
script_out=[headings script_out2(1:end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Write down the output file.  %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

output=fopen(output_name,'w+');
    fprintf(output,script_out);
fclose(output);

return

end
