function [eGapHalf, eGap, fermiDOS] = Read_VASP_DOSCAR(Column, nAtoms)

% this function tries to determine the bandgap from the DOSCAR file
% fermi energy - 4th value in the 6th string 
handle = fopen('DOSCAR');
for i = 1 : 6
    tmp = fgetl(handle);
end

[nothing, numStr] = unix('sed -n "10p" DOSCAR');
NN= length( str2num(numStr) );
line6 = str2num(tmp);
eFermi = line6(4);
if NN == 3
    DOS = fscanf(handle, '%g %g %g', [3 inf]);
    precision = 0.01 * nAtoms;
elseif NN == 5
    DOS = fscanf(handle, '%g %g %g %g %g', [5 inf]);
    precision = 0.001 * nAtoms;  % for half-metal we need more accuracy
end
DOS = DOS';
fclose(handle);

for eF = 1 : size(DOS,1)
    if DOS(eF,1) > eFermi
        break;
    end
end

fermiDOS = DOS(eF,Column) - (DOS(eF,Column) - DOS(eF-1,Column))*(DOS(eF,1) - eFermi)/(DOS(eF,1) - DOS(eF-1,1));
k = (DOS(eF,Column) - DOS(eF-1,Column))/(DOS(eF,1) - DOS(eF-1,1)); % 1st derivative, linear approximation
%%%% GAP between Conducting bond and Fermi level
% integrated DOS at fermi level, linear approximation:
k_prev1 = (DOS(eF-1,Column) - DOS(eF-2,Column))/(DOS(eF-1,1) - DOS(eF-2,1));
k_prev2 = (DOS(eF-2,Column) - DOS(eF-3,Column))/(DOS(eF-2,1) - DOS(eF-3,1));

if (abs(DOS(eF-1,Column) - fermiDOS) > precision) || ((k_prev1 > k) & (k_prev2 > k))
  eGapC = 0; % we got a metal
else
  for i = eF -1 : -1 : 2
    k1 = (DOS(i,Column) - DOS(i-1,Column))/(DOS(i,1) - DOS(i-1,1)); % 1st derivative, linear approximation
    if k1 > k
      break;
    end
  end
  eGapC = eFermi - DOS(i,1); 
end

%%%% GAP between Fermi level and Valence bond
% integrated DOS at fermi level, linear approximation:
k_next1 = (DOS(eF+1,Column) - DOS(eF,Column))/(DOS(eF+1,1) - DOS(eF,1));
k_next2 = (DOS(eF+2,Column) - DOS(eF+1,Column))/(DOS(eF+2,1) - DOS(eF+1,1));

if ((DOS(eF+1,Column) - fermiDOS) > precision) || ((k_next1 > k) & (k_next2 > k))
  eGapV = 0; % we got a metal
else
  for i = eF + 1 : size(DOS,1)
    k1 = (DOS(i,Column) - DOS(i-1,Column))/(DOS(i,1) - DOS(i-1,1)); % 1st derivative, linear approximation
    if k1 > k
      break;
    end
  end
  eGapV = DOS(i-1,1) - eFermi;
end
%%%%%-----------------------------------------
eGapHalf = eGapV * eGapC/(eGapC + eGapV);
eGap = eGapC + eGapV;

if Column == 3
Col = 2;
elseif Column == 4
Col = 2;
elseif Column == 5
Col = 3;
end
fermiDOS = (DOS(eF,Col) - (DOS(eF,Col) - DOS(eF-1,Col))*(DOS(eF,1) - eFermi)/(DOS(eF,1) - DOS(eF-1,1)))/nAtoms;

