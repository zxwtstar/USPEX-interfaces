function Write_ABINIT(Ind_No)
global POP_STRUC
global ORG_STRUC

numIons = POP_STRUC.POPULATION(Ind_No).numIons;
Step    = POP_STRUC.POPULATION(Ind_No).Step;
coord   = POP_STRUC.POPULATION(Ind_No).COORDINATES;
lattice = POP_STRUC.POPULATION(Ind_No).LATTICE;
atomType= ORG_STRUC.atomType;
specificFolder = [ORG_STRUC.homePath, '/', ORG_STRUC.specificFolder];


fp = fopen('input','w');
fprintf(fp,'abinit.in \n');
fprintf(fp,'abinit.out \n');
fprintf(fp,'abi \n');
fprintf(fp,'abo \n');
fprintf(fp,'tmp \n');
for i = 1 : length(numIons)
    fprintf(fp,'%s.psp \n', megaDoof(atomType(i)));
end
fclose(fp);

[status, msg] = unix(['cat ' specificFolder '/abinit_' num2str(Step) ' >  abinit.in']);


fp = fopen('abinit.in','a+');
if ORG_STRUC.dimension == 3 | ORG_STRUC.dimension == 2 
    fprintf(fp, 'ntypat %3d \n' , length(atomType));
    fprintf(fp, 'natom  %3d \n' , sum(numIons));

    typat = findTypat(numIons);
    fprintf(fp, 'typat   ');
    for i = 1 : length(typat)
        fprintf(fp, '%2d ' , typat(i));
    end
    fprintf(fp, ' \n');

    fprintf(fp, 'znucl   ');
    for i = 1 : length(atomType)
        fprintf(fp, '%2d ' , atomType(i));
    end
    fprintf(fp, ' \n');

    %%%% LATTICE
    lattice = latConverter(lattice);
    lattice(4:6) = lattice(4:6)*180/pi;
    fprintf(fp, 'acell %9.3f %8.3f %8.3f  Angstrom \n' , lattice(1:3));
    fprintf(fp, 'angdeg %7.2f %8.2f %8.2f \n' , lattice(4:6));
    
    %%%% COORDINATES
    fprintf(fp, 'xred %8.6f %12.6f %12.6f \n' , coord(1,:));
    for i = 2 : sum(numIons)
        fprintf(fp, '     %8.6f %12.6f %12.6f \n' , coord(i,:));
    end

    %%%% KPOINTS
    [Kpoints, Error] = Kgrid(POP_STRUC.POPULATION(Ind_No).LATTICE, ...
                       ORG_STRUC.Kresol(Step), ORG_STRUC.dimension);
    if Error == 1  % This LATTICE is extremely wrong, let's skip it from now
        POP_STRUC.POPULATION(Ind_No).Error = POP_STRUC.POPULATION(Ind_No).Error + 4;
    else
        POP_STRUC.POPULATION(Ind_No).K_POINTS(Step,:)=Kpoints;
    end
    fprintf(fp,'ngkpt %4d %4d %4d\n', Kpoints(1,:));

    fprintf(fp,'chkprim  0 \n');
    fprintf(fp,'chksymbreak 0 \n');

else
    disp('STOP! Abinit is not performing geometry optimization for nanoclusters!');
end
fclose(fp);

%copyfile('abinit.in',['abinit.in_' num2str(Step) ]);
%%% Note: for relaxation should be:
%%% chkdilatmx 0
%%% optcell 2 


function typat = findTypat(numIons)

typat = zeros(1,sum(numIons));
for a = 1 : length(numIons)
    stpoint = sum(numIons(1:a -1)) + 1;
    typat(stpoint:stpoint + numIons(a) - 1) = a;
end


