function [eGap] = Read_VASP_EIGENVAL(column)

% this function tries to determine the bandgap from the EIGANVAL file
% should be more exact than from DOSCAR for gapped materials
% Line 6: number of electrons, N of K-poins, N of bands
% every k-point: k-point coordinate, weight; then band index, eigenvalue 
% (for spin-polarized systems - 2 columns of eigenvalues for spin up and down respectively).

try
 handle = fopen('EIGENVAL');
 for i = 1 : 6
   tmp = fgetl(handle);
 end
 l6 = str2num(tmp);
 eN = l6(1);
 filledBand = floor(eN/2); % 2 electrons per band
 nK = l6(2); % number of k-points
 nB = l6(3); % number of bands
 [nothing, numStr] = unix('sed -n "10p" EIGENVAL');
 NN= length( str2num(numStr) );
 for i = 1 : nK
   tmp = fgetl(handle); % empty line
   tmp = fgetl(handle); % k point coords and weight
   if NN == 2
   bands = fscanf(handle, '%g %g', [2 nB]); % no spin polarized
   elseif NN == 3
   bands = fscanf(handle, '%g %g %g', [3 nB]); % spin up-down
   end
   bands = bands';
   if i == 1
     gapStart = bands(filledBand, column);
     gapEnd = bands(filledBand+1, column);
   else
     if gapStart < bands(filledBand, column);
       gapStart = bands(filledBand, column);
     end
     if gapEnd > bands(filledBand+1, column);
       gapEnd = bands(filledBand+1, column);
     end
   end
   tmp = fgetl(handle); % EOL char
 end
 fclose(handle);

 eGap = gapEnd - gapStart;
 if eGap < 0
   eGap = 0; % for metals
 end
catch
 eGap = 0;
end
