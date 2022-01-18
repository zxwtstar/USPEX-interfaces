function [coor, lat] = Read_MLIP_Structure()
filename = 'for_read.cfg';
coor = [];
lat = [];
if exist(filename)
    fp = fopen(filename,'r+');
    fgetl(fp);
    fgetl(fp);
    numIons = str2num(fgetl(fp));
    fgetl(fp);
    LATT = zeros(3);
    for i = 1 : 3
        tmp = fgetl(fp);
        LATT(i,:) = str2num(tmp);
    end
    lat = LATT;
    tline = fgetl(fp);
    for j = 1 : numIons
        tline = str2num(fgetl(fp));
        coor(j,:) = tline(3:5);
    end
    coor = coor/lat;
    fclose(fp);
else
    disp(['!!!!!!!!!File ' filename  ' does not exist in this universe!!!!!!!!!']);
end
