function target = Read_MOPAC(flag, ID)
if     flag == 0
    [nothing, results] = unix('grep --text  " == MOPAC DONE ==" input.out');
    [nothing, results1] = unix('grep --text  "TOTAL ENERGY            =" input.out');
    if ~isempty(results) & ~isempty(results1)
        disp(['| MOPAC completely Done at ' ID]);
        target = 1;
    else
        disp('MOPAC is not completely Done');
        unixCmd(['cp input.out ERROR-OUTPUT-' ID]);
        target = 0;
    end
elseif flag == -1  %let's skip this option for now, it's for later
    [nothing, results1] = unix('grep --text "I DONT THE ERROR" input.out');
    if ~isempty(results1)
        unixCmd(['cp input.out ERROR-OUTPUT-' ID]);
        target = 0;
    else
        disp(['* MOPAC completely Done at ' ID]);
        target = 1;
    end
elseif flag ==  1
    [nothing, results] = unix('./getStuff  input.out "TOTAL ENERGY" 5 | tail -1');
    target = str2num(results);
end
