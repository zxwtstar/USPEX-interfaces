function target = Read_LAMMPS(flag)

if flag == -1
    [nothing, results] = unix('grep --text "Minimization stats" lammps.out');
    if isempty(results)
        disp('Lammps is not completely Done');
        target = 0;
    else
        target = 1;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif flag == 0
    if exist('lammps.out')
        target = 1;
        [nothing, results] = unix('grep --text energy lammps.out');
        if isempty(results)
            target = 0;
        end
        [nothing, results] = unix('grep --text volume lammps.out');
        if isempty(results)
            target = 0;
        end
        [nothing, results] = unix('grep --text "iso" lammps.in');
        if isempty(results)
            target = 0;
        end
    else
        target=0;
    end
    
    if target==0
        unixCmd('cp lammps.in lammps.in.error');
        unixCmd('cp lammps.out lammps.out.error');
        unixCmd('cp coo coo.error');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif flag ==  1
    [nothing, results] = unix('grep --text "iso" lammps.in | grep --text -v "^#"');
    
    if size(ver('Octave'),1)
        OctaveMode = 1;
    else
        OctaveMode = 0;
    end
    
    tmp1 = results;
    tmp2 = deblank(tmp1);
    str=tmp2;
    if str(1)~='#' && str(1)~='!' && str(1)~='%'
        if OctaveMode
            for i=1:50
                tmp2 = strrep(tmp2, '  ', ' ');
            end
            tmp3= strsplit(tmp2, ' ');
        else
            tmp3= regexp(tmp2, '\s', 'split');
        end
        
        if strcmp(tmp3{4},'box/relax')
            press=str2num(tmp3{6});
        end
        if strcmp(tmp3{4},'npt')
            press=str2num(tmp3{11});
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fp=fopen('lammps.out','r');
    error=0;
    while 1
        tline = fgetl(fp);
        if ~isempty(findstr(tline, 'energy'))
            tline=fgetl(fp);
            energy=sscanf(tline,'%f');
        elseif ~isempty(findstr(tline, 'press'))
            tline=fgetl(fp);
            pp=sscanf(tline,'%f');
            if exist('press')
                unixCmd(['echo ' num2str(pp) '>>press']);
            else
                unixCmd(['echo ' num2str(pp) '>press']);
            end
        elseif ~isempty(findstr(tline, 'volume'))
            tline=fgetl(fp);
            vol=sscanf(tline,'%f');
        end
        if ~ischar(tline)
            fclose(fp);
            break;
        end
    end
    
    target = energy+vol*press/1e4/160.2176487; %1eV = 160.2176487 GPa*A^3
end
end
