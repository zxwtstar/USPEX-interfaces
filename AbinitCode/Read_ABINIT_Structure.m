function [coor, lat] = Read_ABINIT_Structure()

coor = [];
lat = [];

[nothing, natom] = unix('grep natom abinit.out');
sumIons = str2num(natom(end - 4 : end));

[nothing, coor] = unix(['grep "Reduced coordinates" abinit.out -A ' num2str(sumIons) ' | tail -' num2str(sumIons) '']);
coor = str2num(coor);


[nothing, lat] = unix('grep " Real space primitive" abinit.out -A 3 | tail -3');
lat = str2num(lat);
Bohr = 0.529177; %Angstrom
lat = Bohr * lat;

unixCmd('rm -rf abo_*');
