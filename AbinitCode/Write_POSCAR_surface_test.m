function Write_POSCAR_surface_test(Ind_No)

% USPEX Version 7.3.5
% Change: order added
global POP_STRUC
global ORG_STRUC


atomType= ORG_STRUC.atomType;
lattice = POP_STRUC.POPULATION(Ind_No).LATTICE;
coord   = POP_STRUC.POPULATION(Ind_No).COORDINATES;
numIons = POP_STRUC.POPULATION(Ind_No).numIons;
count   = POP_STRUC.bodyCount;
step    = POP_STRUC.POPULATION(Ind_No).Step;


thicknessB = thicknessBORG_STRUC.thicknessB
lat_bulk   =latConverter(POP_STRUC.POPULATION(Ind_No).Bulk_LATTICE);

content  = POSCARContent_Surface( atomType, count, 'no SG', numIons, lattice, coord, lat_bulk, thicknessB, step );

writeContent2File('POSCAR', content, 'w');



%Lattice_par = latConverter(lat);
%Lattice_par(4:6) = Lattice_par(4:6)*180/pi;

%symg='no SG';

%if size(coord,1) ~= sum(numIons)
%   %disp(['Warning:  dimension of coordinates is inconsistent with numIons']);
%   USPEXmessage(530,'',0);
%   disp(pwd);
%end

%fp = fopen('POSCAR', 'w');
%fprintf(fp, 'EA%-4d %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f Sym.group: %4s\n', bodyCount, Lattice_par(1:6), symg);
%fprintf(fp, '1.0000\n');

%for latticeLoop = 1 : 3
%   fprintf(fp, '%12.6f %12.6f %12.6f\n', lat(latticeLoop,:));
%end

%for i=1:length(numIons)
%   fprintf(fp, '%4d ', numIons(i));
%end
%   fprintf(fp, '\n');
%   fprintf(fp, 'Selective dynamics\n');
%   fprintf(fp, 'Direct\n');

%for i=1:size(coord,1)
%    if POP_STRUC.POPULATION(Ind_No).chanAList(i)==1
%       fprintf(fp, '%12.6f %12.6f %12.6f  T  T  T\n', coord(i,:));
%    else
%      if POP_STRUC.POPULATION(Ind_No).Step == 1
%         fprintf(fp, '%12.6f %12.6f %12.6f  F  F  F\n', coord(i,:));
%      else
%          if coord(i,3)*Lattice_par(3) > lat_bulk(3) - ORG_STRUC.thicknessB
%              fprintf(fp, '%12.6f %12.6f %12.6f  T  T  T\n', coord(i,:));
%          else
%              fprintf(fp, '%12.6f %12.6f %12.6f  F  F  F\n', coord(i,:));
%          end
%      end
%    end
%end
%fclose(fp);
