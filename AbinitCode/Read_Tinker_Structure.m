function PROTEINS_STRUC = Read_Tinker_Structure(backbone_atoms)
% $Rev$
% $Author$
% $Date$

%function PROTEINS_STRUC = Read_Tinker_Structure()
%backbone_atoms = [9    19    29    39    49    59    69    79];

global ORG_STRUC

[A, B, C] = textread('input_stable.angles', '%s %s %s');
angles    = [str2double(B(2:end)), str2double(C(2:end))];
residues  = A(2:end);


PROTEINS_STRUC = backbone('input.xyz_3', backbone_atoms);
PROTEINS_STRUC.angles   = angles;
PROTEINS_STRUC.residues = residues;

sec_list = {};
if size(angles, 1) >= 0     % limitation of stride program
    % stride EA0004.pdb | sed 's/REM/\nREM/g; s/ASG/\nASG/g; s/HDR/\nHDR/g; s/CMP/\nCMP/g; s/SRC/\nSRC/g; s/CHN/\nCHN/g; s/SEQ/\nSEQ/g; s/STR/\nSTR/g; s/LOC/\nLOC/g'; echo
    [stat, stride_out] = unix([ORG_STRUC.USPEXPath '/FunctionFolder/USPEX/M400/stride input_stable.pdb']);
    k = strfind(stride_out, 'ASG ');
    if stat == 0
        for i=1:(size(k, 2))
            if i < (size(k, 2))
                sec_string = stride_out(k(i):k(i+1));
            else
                sec_string = stride_out(k(end):end);
            end
            
            % Parse the output strings from stride:
            % ASG  ALA -    2    1    C          Coil    360.00    171.39     157.1      A
            % Secondary structure is 7th element in the array:
            sec_structure = textscan(sec_string, '%s %s %s %d %d %s %s %f %f %f %s');
            sec_list{i} = sec_structure{7}{1};
        end
    else
        for i=1:(size(angles, 1))
            sec_list{i} = 'Coil';
        end
    end
end

PROTEINS_STRUC.secondary_structure = sec_list;


% [MR]: Probably I'll need to move this part to other function/module:
unixCmd(['cat /dev/null         > ' ORG_STRUC.homePath '/PDB']);
unixCmd(['cat input_stable.pdb  > ' ORG_STRUC.homePath '/PDB']);

unixCmd(['cat /dev/null         > ' ORG_STRUC.homePath '/MAKE']);
unixCmd(['cat input_stable.make > ' ORG_STRUC.homePath '/MAKE']);

% Print POSCARs:
unixCmd(['cat /dev/null           > ' ORG_STRUC.homePath '/POSCAR']);
unixCmd(['cat POSCAR_backbone     > ' ORG_STRUC.homePath '/POSCAR']);

end
