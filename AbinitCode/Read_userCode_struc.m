function [COORDS, LATT] = Read_userCode_struc()

if ~exist('geom.out')
    copyfile geom.in geom.out;
end

%% The geom.out is in the format of POSCAR
[fid,message] = fopen('geom.out');
tmp = fgetl(fid); % system description
tmp = fgetl(fid); % scaling_factor
scale_factor = str2num(tmp);

LATT = zeros(3);
for i = 1 : 3
  tmp = fgetl(fid);
  LATT(i,:) = str2num(tmp);
end
LATT = LATT*scale_factor; 

tmp = fgetl(fid); % numIons
ntype = str2num(tmp);
if isempty(ntype)   % vasp 5.2 has a line with atomic names before numIons!
 tmp = fgetl(fid); % numIons
 ntype = str2num(tmp);
end
natom = sum(ntype);

tmp_mode = fgetl(fid);
if (tmp_mode(1) == 's') || (tmp_mode(1) == 'S') % selective mode
  tmp_mode = fgetl(fid);
  sss = fscanf(fid,'%g %g %g %s %s %s',[6,natom]);
else
  sss = fscanf(fid,'%g %g %g',[3,natom]);
end
ss=sss';
COORDS = ss(:,1:3);

fclose(fid);

if (tmp_mode(1) == 'c') || (tmp_mode(1) == 'C') || (tmp_mode(1) == 'k') || (tmp_mode(1) == 'K') % Cartesian
  COORDS = COORDS*scale_factor;
  COORDS = COORDS/LATT;
end
%% the local optimizer may not constrain the coordinates to [0,1], so we do this now.
COORDS = COORDS - floor(COORDS);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

delete geom.out
