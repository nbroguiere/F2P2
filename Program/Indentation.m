function [] = Indentation(input_name)
%INDENTATION makes a LAS - Live data mode *.lrp file human-readable. 
%
% Generates an output named as the input, with a "fixed" suffix, in the
% current working directory. 
% 
% Files can be too long for notepad to handle, we recommend notepad++
%
% Copyright Nicolas Broguiere 2012-2019

output_name=[input_name(1:end-4) ' fixed.' input_name(end-2:end)]
script=fileread(input_name);

script=strrep(script, sprintf('\t'), '');
script=strrep(script, char(13), sprintf(''));
script=strrep(script, sprintf('\n'), '');
script=regexprep(script,'>[ ]*<','><');

%%%%%%%%%%%% NEW LINES %%%%%%%%%%%%%

script=strrep(script, '>', '>\n');

%%%%%%%%%%% TABULATIONS %%%%%%%%%%%%

tmp=strfind(script(1:300), '<Configuration');
headings=script(1:tmp-1);
script=script(tmp:end);

newlines=strfind(script, '>');
n=size(newlines,2);

% Everything calibrated to give the position of the bracket.
open2=strfind(script,'</');     %1
open2=[open2;ones(1,size(open2,2))];
close2=strfind(script,'/>')+1;  %2
close2=[close2;2*ones(1,size(close2,2))];
open=strfind(script,'<');       %3
open=[open;3*ones(1,size(open,2))];
close=strfind(script,'>');      %4
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

script_out2=blanks(counter+size(script,2));

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
            script_out2(brackets(n-i+1,1)+counter-sum_j:last_bracket+counter-sum_j-1)=script(brackets(n-i+1,1):last_bracket-1);
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
script=[headings script_out2(1:end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Write down the output file.  %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

output=fopen(output_name,'w+');
    fprintf(output,script);
fclose(output);

return

end

