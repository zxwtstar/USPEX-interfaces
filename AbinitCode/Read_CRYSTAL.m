function target = Read_CRYSTAL(flag, ID)
Ha = 27.211385;
if flag == 0
  [nothing, resDone] = unix('grep "Pcrystal finished normally" CRYSTAL.o');
  [nothing, results] = unix('grep "FINAL OPTIMIZED GEOMETRY" CRYSTAL.o');
  if ~isempty(resDone)
    disp('CRYSTAL is done successfully.');
    target = 1;
  elseif ~isempty(results)
    disp('CRYSTAL is not fully converged.');
    target = 1;  
  else
    disp('CRYSTAL optimization is NOT done successfully.');
    target = 0;
  end
elseif flag == 1
  [nothing, results] = unix('grep " * OPT END" CRYSTAL.o | awk ''{print $8}''');
  energy = str2num(results);
  target = energy * Ha;
end
