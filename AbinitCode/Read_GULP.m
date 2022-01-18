function target = Read_GULP(flag, ID)
%This routine is used to read flags from gulp output
%-1: if GULP is complete (For NEB)
%-0: if 1st SCF is done (for USPEX)
% 1: energy/enthalpy
% 2: pressue tensor
% 3: dielectric constant
% 6: elastic constant matrix (array data)
% 7: atomic forces

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if     flag == -1
    [nothing, results] = unix('grep --text Finished output');
    if isempty(results)
        USPEXmessage(1151,'',0);
        target = 0;
    else
        target = 1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif flag == 0
    target = 1;
    [nothing, results] = unix(['./getStuff output Energy 5 |tail -1']);
    if isempty(results) || isempty(str2num(results))
        USPEXmessage(1152,'',0);
        target = 0;
    else
        [nothing, results3] = unix(['grep --text dump optimized.structure']);
        if isempty(results3)
            target = 0;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif flag ==  1 %
    [nothing, Energy_Str] = unix(['./getStuff output Energy 5 |tail -1']);
    target = str2num(Energy_Str);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif flag ==  2 % Pressure Tensor
    %[nothing, prestenStr] = unix('awk -f GULP_pres.awk output');
    %target = str2num(prestenStr);
    target = callAWK('GULP_pres.awk','output');
    %USPEXmessage(1153,'',0);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif ( flag ==  3 ) | ( flag == 10 ) % Diel or Birefringence
    CheckPoint = 0;
    d_s = zeros(1,6);
    d_s_ion = zeros(1,6);
    Diel_Tens = zeros(3);
    [fileHandle, msg] = fopen('output');
    while 1
        tline = fgetl(fileHandle);
        if ~ischar(tline)
            break
        end
        try
            if ~isempty(strfind(tline, 'Static dielectric constant'))
                tline = fgetl(fileHandle);
                tline = fgetl(fileHandle);
                tline = fgetl(fileHandle);
                tline = fgetl(fileHandle);
                tline1 = fgetl(fileHandle);
                e_tensor = sscanf(tline1,'%*s %g %g %g');
                Diel_Tens(1,:) = e_tensor;
                d_s(1) = e_tensor(1);
                d_s(4) = e_tensor(2);
                d_s(5) = e_tensor(3);
                tline2 = fgetl(fileHandle);
                e_tensor = sscanf(tline2,'%*s %g %g %g');
                Diel_Tens(2,:) = e_tensor;
                d_s(2) = e_tensor(2);
                d_s(6) = e_tensor(3);
                tline3 = fgetl(fileHandle);
                e_tensor = sscanf(tline3,'%*s %g %g %g');
                Diel_Tens(3,:) = e_tensor;
                d_s(3) = e_tensor(3);
                CheckPoint = 1;
            end
        catch
            d_s(1:6) = -100000 * [ 1 1 1 1 1 1 ];
        end
    end
    fclose(fileHandle);
    %USPEXmessage(1154,'',0);
    if flag  == 10
        if CheckPoint == 1
            DiagMat = eig(Diel_Tens);
            Birefringence = sqrt(max(DiagMat)) - sqrt(min(DiagMat));
            for a = 1 : length(DiagMat)
                if ( DiagMat(a) > 99 ) | ( DiagMat(a) < 1 ) | (d_s(a) < 0)
                    Birefringence = -100000;
                    break;
                end
            end
            target = Birefringence;
        else
            target = -100000;
        end
    elseif flag == 3
        target = d_s;
    end
    
elseif flag ==  6 % % Elastic properties
    elas_orig = callAWK('GULP_elas.awk', 'output');   %% unixCmd('awk -f GULP_elas.awk output');
    try
        elasticMatrix = elas_orig([1,2,3,4,5,6],:);
    catch
        %disp('Warning : Cannot extract Elastic Constant Matrix from GULP output file! ');
        USPEXmessage(1155, '', 0);
        elasticMatrix=[];
    end
    target = elasticMatrix;
elseif  flag ==  7 % atomic forces
    try
        [nothing, numStr] = unix(['grep --text "Total number atoms/shells" output |cut -d"=" -f2']);
        numIons= sum( str2num(numStr) );
        force_orig = callAWK('GULP_force.awk', 'output', ['num=', num2str(numIons)]);
        if isempty(force_orig)
            USPEXmessage(1156,'',0);
            target = [];
        else
            target = force_orig;
        end
    catch
        target = [];
    end
end
