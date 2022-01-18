function target = Read_MLIP(flag)
filename = 'for_read.cfg';
if flag == 1
    [nothing, results] = unix(['grep --text -A1 "Energy" ' filename ' | tail -1']);
    if length(results) < 2 | isempty(results) | ~exist(filename)
        target = 999;
        disp(['Structure has no energy!']);
    else
        target = str2num(results);
        disp(['Structure with E=' num2str(target) ' was read.']);
    end
elseif flag == 0  % if Calc is done correctly
%%% MLIP object has been destroyed
    if exist(filename)
        [nothing, results] = unix(['grep --text -A1 "Energy" ' filename '| tail -1']);
        target = 1;
        if isempty(results)
            target = 0;
        end
    else
        target = 0;
    end
end
