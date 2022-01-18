function target = Read_userCode(flag, Step)

global ORG_STRUC

target = python_uspex([ORG_STRUC.USPEXPath '/FunctionFolder/Tool/userCalcFitness.py'], num2str(flag), num2str(Step));
target = str2num(target);
% 0: if 1st SCF is done & SCF is converged
% 1: energy/enthalpy
%-1: collect all energy
% 2: pressue tensor
%-2: all pressure tensor
% 3: dielectric constant
% 4: gap
% 5: magmoment
%-5: atomic magmoments
% 6: elastic constant matrix (array data)
% 7: atomic forces
% 8: relaxation atomic positions
% 9: relaxation lattice paramter
%10: birefringence
%11: half-metal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if flag == 3
    target = target * ones(1,6);
end
