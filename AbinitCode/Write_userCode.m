function Write_userCode(Ind_No)

global POP_STRUC
global ORG_STRUC

inp.symg    = POP_STRUC.POPULATION(Ind_No).symg;
inp.count   = POP_STRUC.POPULATION(Ind_No).Number;
inp.Step    = POP_STRUC.POPULATION(Ind_No).Step;
inp.lattice = POP_STRUC.POPULATION(Ind_No).LATTICE;
inp.coor    = POP_STRUC.POPULATION(Ind_No).COORDINATES;
inp.numIons = POP_STRUC.POPULATION(Ind_No).numIons;


try
   unixCmd(['cat userInput_' num2str(inp.Step) ' > input']);
catch
end

inp.varcomp = ORG_STRUC.varcomp;
inp.atomType = ORG_STRUC.atomType;
inp.dimension = ORG_STRUC.dimension;
inp.abinitioCode = ORG_STRUC.abinitioCode;
inp.spin = ORG_STRUC.spin;
inp.pressure = ORG_STRUC.ExternalPressure;

[Kpoints, Error] = Kgrid(inp.lattice, ORG_STRUC.Kresol(inp.Step), inp.dimension);
inp.Kpoints = Kpoints;
% --------- POSCAR ------------
if inp.dimension == 2
    Write_POSCAR_surface(Ind_No);
elseif inp.dimension == -3
    writeOUT_POSCAR_GB(Ind_No);
else
    Write_POSCAR(inp.atomType, inp.count, inp.symg, inp.numIons, inp.lattice, inp.coor);   %vasp5-format
end
movefile POSCAR geom.in;
%------- JSON : writing possible inputs
warning('off');
txt = jsonencode(inp);
fp = fopen('parameters.json','w');
fprintf(fp, txt);
fclose(fp);
warning('on');
