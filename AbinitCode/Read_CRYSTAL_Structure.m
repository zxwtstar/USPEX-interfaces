function [coor, lat] = Read_CRYSTAL_Structure()

% Get lattice
latCommand = ['grep " DIRECT LATTICE VECTORS CARTESIAN COMPONENTS" CRYSTAL.o -A 4 | tail -3'];
[nothing, lattice] = unix(latCommand);
lat = str2num(lattice);

% Get number of atoms in the unitcell
[nothing, N] = unix('grep " ATOMS IN THE ASYMMETRIC UNIT" CRYSTAL.o');
numIons = str2num(N(end-4:end));

% Get fraction coordinates from output - this is not exactly fraction coordinates
% So, I would rather using direct coordinates.
%fCoorCommand = ['grep " ATOMS IN THE ASYMMETRIC UNIT" CRYSTAL.o -A ' num2str(numIons + 2) ...
%    ' | tail -' num2str(numIons) ' | awk ''{print $5,$6,$7}'''];
%[nothing, fracCoor] = unix(fCoorCommand);
%fraccoor = str2num(fracCoor);


% Get cartesian coordinates from CRYSTAL.o
coordCommand = ['grep " CARTESIAN COORDINATES - PRIMITIVE CELL" CRYSTAL.o -A ' num2str(numIons + 3) ...
' | tail -' num2str(numIons) ' | awk ''{print $4,$5,$6}'''];

[nothing, coordinate] = unix(coordCommand);
coordinate = str2num(coordinate);
coor = coordinate/lat;
