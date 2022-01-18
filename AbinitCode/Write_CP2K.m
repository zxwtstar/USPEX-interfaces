function Write_CP2K(Ind_No)


% USPEX Version 8.3.2
% Change: created

global POP_STRUC
global ORG_STRUC

numIons     = POP_STRUC.POPULATION(Ind_No).numIons;
Step        = POP_STRUC.POPULATION(Ind_No).Step;
COORDINATES = POP_STRUC.POPULATION(Ind_No).COORDINATES;
LATTICE     = POP_STRUC.POPULATION(Ind_No).LATTICE;
atomType    = ORG_STRUC.atomType;
dimension   = ORG_STRUC.dimension;
kBar_ExPressure = ORG_STRUC.ExternalPressure * 10;
%-----------------------------------------------------------
cp2k_inp = ['cp2k_options_' num2str(Step) ];
if exist(cp2k_inp)
    copyfile(cp2k_inp, 'cp2k.inp');
    
    Lattice = latConverter(LATTICE);
    Lattice = Lattice';
    Lattice(4:6) = Lattice(4:6) * 180 / pi;
    
    fp  = fopen('subsys.uspex'  ,'w');
    fp2 = fopen('pressure.uspex','w');
    [nothing, output] = unix('grep SUBSYS cp2k.inp');
    
    if isempty(output)
        fprintf(fp, '&SUBSYS\n');
    end
    fprintf(fp, '&CELL\n');
    fprintf(fp, 'ABC [angstrom] %9.5f %9.5f %9.5f\n', Lattice(1:3));
    fprintf(fp, 'ALPHA_BETA_GAMMA [deg] %6.1f %6.1f %6.1f\n', Lattice(4:6));
    
    if     dimension == 3
        fprintf(fp, 'PERIODIC XYZ\n');
    elseif dimension == 2
        fprintf(fp, 'PERIODIC XY\n');
    elseif dimension == 0
        fprintf(fp, 'PERIODIC NONE\n');
    end
    
    fprintf(fp, '&END\n');
    fprintf(fp, '&COORD\n');
    fprintf(fp, 'SCALED\n');
    coordLoop = 1;
    for i = 1 : length(numIons)
        for j = 1 : numIons(i)
            fprintf(fp, '%2s %8.5f %8.5f %8.5f\n', megaDoof(atomType(i)), COORDINATES(coordLoop,:));
            coordLoop = coordLoop + 1;
        end
    end
    fprintf(fp, '&END\n');
    
    if isempty(output)
        fprintf(fp, '&END SUBSYS\n');
    end
    fclose(fp);

    fprintf(fp2, 'EXTERNAL_PRESSURE [kbar] %5.1f\n', kBar_ExPressure);
    fclose(fp2);

    [nothing, out_kpoint] = unix('grep KPOINTS cp2k.inp');
    if ~isempty(out_kpoint)
	fp3 = fopen('kpoints.uspex','w');
        [Kpoints, Error] = Kgrid(LATTICE, ORG_STRUC.Kresol(Step), dimension);
        if Error == 1
            POP_STRUC.POPULATION(Ind_No).Error = POP_STRUC.POPULATION(Ind_No).Error + 4;
        else
            POP_STRUC.POPULATION(Ind_No).K_POINTS(Step,:) = Kpoints;
        end
        fprintf(fp3, 'SCHEME MONKHORST-PACK %4d %4d %4d\n', Kpoints(1,:));
        fclose(fp3);
    end
else
    disp(['"' cp2k_inp '" does not exist!']);
    quit
end
