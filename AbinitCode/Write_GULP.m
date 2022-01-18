function Write_GULP(Ind_No)

% USPEX Version 8.1.1
% Change: added surface support

global POP_STRUC
global ORG_STRUC

format compact

if exist('output')
    delete('output');
end

if exist('optimized.structure')
    delete('optimized.structure');
end

step = POP_STRUC.POPULATION(Ind_No).Step;
try
    unixCmd(['cat goptions_' num2str(step) ' > input']);
catch
    disp('OOPPSS, no ginput_*');
end


if ORG_STRUC.molecule==1
    [a, connect] = unix(['grep --text connect ginput_' num2str(step)]);
    if isempty(connect)
        disp(['Connectivity is not specfied by GULP, will be generated automatically']);
        TO_write = 1;
    else
        TO_write = 0;
    end
    Write_GULP_MOL(Ind_No, TO_write);
else
    %   if ORG_STRUC.dimension == 2
    %      writeCalcFilesGULP_surface(Ind_No);
    %   else
    numIons = POP_STRUC.POPULATION(Ind_No).numIons;
    for ind = 1:length(numIons)
        ionChange(ind) = sum(numIons(1:ind));
    end
    ionCh = zeros (1,length(ionChange)+1);
    ionCh(2:end) = ionChange;

    fp = fopen('input','a+');
    fprintf(fp, 'cell\n');

    Lattice = latConverter(POP_STRUC.POPULATION(Ind_No).LATTICE);

    if size(Lattice,1)==1
        Lattice = Lattice';
    end
    Lattice(4:6)=Lattice(4:6)*180/pi;

    if (ORG_STRUC.dimension == -3) || (ORG_STRUC.dimension == 2)
        fprintf(fp, '%7.3f %7.3f %7.3f %7.3f %7.3f %7.3f 0 0 0 0 0 0\n', Lattice(1:6));
    else
        fprintf(fp, '%7.3f %7.3f %7.3f %7.3f %7.3f %7.3f\n', Lattice(1:6));
    end
    fprintf(fp, 'fractional\n');

    for someInd = 1:length(POP_STRUC.POPULATION(Ind_No).numIons)
        label = [megaDoof(ORG_STRUC.atomType(someInd))];
        for coordLoop = (ionCh(someInd)+1):ionCh(someInd+1)
            coor = POP_STRUC.POPULATION(Ind_No).COORDINATES(round(coordLoop),:);
            if (ORG_STRUC.dimension == -3) || (ORG_STRUC.dimension == 2)
                if POP_STRUC.POPULATION(Ind_No).chanAList(coordLoop)==1
                    fprintf(fp, '%4s %12.6f %12.6f %12.6f 1 1 0 1 1 1\n', label, coor(1,:));
                else
                    fprintf(fp, '%4s %12.6f %12.6f %12.6f 1 1 0 0 0 0\n', label, coor(1,:));
                end
            else
                fprintf(fp, '%4s %12.6f %12.6f %12.6f\n', label, coor(1,:));
            end
        end
    end
    fclose(fp);
    %   end
end

try
    unixCmd(['cat ginput_' num2str(step) ' >> input']);

    fp = fopen('input', 'a+');
    fprintf(fp, '\n');
    % unixCmd(['echo ' ' >> input']);  %in case the new text is added to the last line

    if ~isempty(ORG_STRUC.ExternalPressure)
        fprintf(fp, ['pressure ' num2str(ORG_STRUC.ExternalPressure) '\n']);
        % unixCmd(['echo pressure >> input']);
        % unixCmd(['echo ' num2str(ORG_STRUC.ExternalPressure) ' >> input']);
    end
    fprintf(fp, 'dump every optimized.structure\n');
    % unixCmd(['echo dump every optimized.structure >> input']);
    fclose(fp);
catch
    disp('NO enough ginput')
    quit
end
