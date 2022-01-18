function [coor, lat] = Read_QE_Structure()
%This rountine is to read structure from QE
%File: output (6.2)
%Last updated by a.kvashnin (2020/04/24)
%clear all;

bohr = 0.529177; % Angstrom
[nothing,line_calc] = unix('grep calculation qe.in');

% Case of calculation = vc-relax, there IS CELL_PARAMETERS in output
if findstr('vc-relax',line_calc)
    [nothing, tmplat] = unix('grep --text -A 3 CELL_P output | tail -3');
    lat = str2num(tmplat);
    lat = lat*bohr;
else
    % Case of calculation = relax, there is NO CELL_PARAMETERS in output file
    %     crystal axes: (cart. coord. in units of alat)
    %          a(1) = (   1.000000   0.000000   0.000000 )
    %          a(2) = (   0.000000   1.200794   0.000000 )
    %          a(3) = (  -0.424832  -0.433458   0.820128 )
    [nothing, scaleStr] = unix('./getStuff output "lattice parameter" 6 | tail -1');
    scale_fac = str2num(scaleStr);
    %[a,LAT]=unix('awk -f QE_cell.awk output |tail -3');
    %lat = str2num(LAT);
    
    lat = callAWK('QE_cell.awk', '| tail -3', 'output');
    lat = lat*bohr;
    lat = lat*scale_fac;
end


[a,SCF]=unix('grep --text ATOMIC_POSITIONS output | wc -l');  %
scf = str2num(SCF);

%ATOMIC_POSITIONS (crystal)
%C        0.543835497   0.918532250   0.208306261
%C        0.596276457   0.404105264   0.975908592
%C        0.881126213   0.565692840   0.022620716
%C        0.450922873   0.080898506   0.853660863
%[a,COOR]=unix('awk -f QE_atom.awk output');
%COOR = str2num(COOR);
COOR = callAWK('QE_atom.awk','output');

numIons = size(COOR,1)/scf;
if scf > 1
    COOR(1:numIons*(scf-1),:)=[];
end
coor = COOR;
