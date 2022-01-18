function  Write_MLIP(Ind_No)
% created by Alexander Kvashnin, modified by ZX (Jun 1, 2019).

global POP_STRUC
global ORG_STRUC

Step = POP_STRUC.POPULATION(Ind_No).Step;
numIons= POP_STRUC.POPULATION(Ind_No).numIons;

filename = 'for_relax.cfg';

fp = fopen(filename, 'a');
fprintf(fp, 'BEGIN_CFG\n');
fprintf(fp, ' Size\n');
fprintf(fp, ' %4d\n', sum(numIons));
fprintf(fp, ' Supercell\n');

cell = POP_STRUC.POPULATION(Ind_No).LATTICE;

for a = 1 : 3
    fprintf(fp, '%22.6f %13.6f %13.6f\n', cell(a,:));
end
fprintf(fp, ' AtomData:   id   type   cartes_x   cartes_y   cartes_z\n');

coor = POP_STRUC.POPULATION(Ind_No).COORDINATES;
coor = coor * cell;
coordLoop = 1;

for i = 1 : length(numIons)
    for j = 1 : numIons(i)
        fprintf(fp, '%15d  %4d %10.4f %10.4f %10.4f\n', coordLoop, ORG_STRUC.atomType(i), coor(coordLoop,:));
        coordLoop = coordLoop + 1;
    end
end
fprintf(fp, 'END_CFG\n');
fclose(fp);

