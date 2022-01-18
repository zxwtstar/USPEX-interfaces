function write_QE_surface(Ind_No)
global POP_STRUC
global ORG_STRUC
lat_bulk=latConverter(POP_STRUC.POPULATION(Ind_No).Bulk_LATTICE);
lat = POP_STRUC.POPULATION(Ind_No).LATTICE;
coord = POP_STRUC.POPULATION(Ind_No).COORDINATES;
numIons = POP_STRUC.POPULATION(Ind_No).numIons;
Step = POP_STRUC.POPULATION(Ind_No).Step;
bodyCount = POP_STRUC.bodyCount;
Lattice_par = latConverter(lat);
Lattice_par(4:6) = Lattice_par(4:6)*180/pi;
symg='no SG';
if size(coord,1) ~= sum(numIons)
%disp(['Warning:  dimension of coordinates is inconsistent with numIons']);
USPEXmessage(530,'',0);
[nothing, nothing] = unix('pwd');
end

%% insertion by SL
%% making qe.in file from Specific/qEspresso_options_<nstep>; add "nat" and "nbnd"
fid = fopen(['qEspresso_options_' num2str(Step)],'rt');
fp = fopen('qe.in','wt');
ss = 0;
while ss~=-1
    ss = fgets(fid);
    if ss~=-1
        fwrite(fp, ss);
        if ~isempty(findstr('SYSTEM',ss))
            fprintf(fp, ['nat = ' num2str(sum(numIons)) '\n']);
        end
    end
end
fclose(fid);

%% writing cell and coordinates to the end of qe.in
bohr = 0.529177;
fprintf(fp, 'CELL_PARAMETERS bohr\n');
% lat1 = latConverter(lat);
% lat = latConverter(lat1);
lat = lat/bohr;
for latticeLoop = 1 : 3
    fprintf(fp, '%12.6f %12.6f %12.6f\n', lat(latticeLoop,:));
end

fprintf(fp, 'ATOMIC_POSITIONS {crystal} \n');
coordLoop = 1;
for i = 1 : length(numIons)
for j = 1 : numIons(i)
    fprintf(fp, '%4s   ', megaDoof(ORG_STRUC.atomType(i)));
    if POP_STRUC.POPULATION(Ind_No).chanAList(coordLoop)==1
        fprintf(fp, '%12.6f %12.6f %12.6f  1  1  1\n', coord(coordLoop,:));
    else
        if POP_STRUC.POPULATION(Ind_No).Step == 1
            fprintf(fp, '%12.6f %12.6f %12.6f  0  0  0\n', coord(coordLoop,:));
        else
            if coord(coordLoop,3)*Lattice_par(3) > lat_bulk(3) - ORG_STRUC.thicknessB
                fprintf(fp, '%12.6f %12.6f %12.6f  1  1  1\n', coord(coordLoop,:));
            else
                fprintf(fp, '%12.6f %12.6f %12.6f  0  0  0\n', coord(coordLoop,:));
            end
        end
    end
    coordLoop = coordLoop + 1;
end
end

[Kpoints, Error] = Kgrid(lat, ORG_STRUC.Kresol(Step), ORG_STRUC.dimension);
if Error == 1
    POP_STRUC.POPULATION(Ind_No).Error = POP_STRUC.POPULATION(Ind_No).Error + 4;
else
    POP_STRUC.POPULATION(Ind_No).K_POINTS(Step,:)=Kpoints;
end
fprintf(fp, 'K_POINTS {automatic} \n');
fprintf(fp, '%4d %4d %4d  0 0 0\n', Kpoints(1,:));
fclose(fp);

