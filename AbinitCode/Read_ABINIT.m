function target = Read_ABINIT(flag, ID)
if     flag == 0
	[nothing, results] = unix('grep --text " Calculation completed"  abinit.out');
	[nothing, results1] = unix('grep --text " Total energy(eV)"  abinit.out');
	if ~isempty(results) & ~isempty(results1)
                disp(['Abinit is completely Done at ' ID]);
                target = 1;
	else
		disp('Abinit is not completely Done!');
		unixCmd(['cp abinit.out ERROR-OUTPUT-' ID]);
		target = 0;
	end
elseif flag ==  1 
	[nothing, results] = unix('./getStuff abinit.out "Total energy" 4 | tail -1');
	target = str2num(results);
end
