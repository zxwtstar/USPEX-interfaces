function  Write_VASP(Ind_No)
%USPEX will check if the POTCAR is complete
%lastly updated by Qiang Zhu (2013/11/22)

global POP_STRUC
global ORG_STRUC

symg    = POP_STRUC.POPULATION(Ind_No).symg;
count   = POP_STRUC.POPULATION(Ind_No).Number;
Step    = POP_STRUC.POPULATION(Ind_No).Step;
lattice = POP_STRUC.POPULATION(Ind_No).LATTICE;
coor    = POP_STRUC.POPULATION(Ind_No).COORDINATES;
numIons = POP_STRUC.POPULATION(Ind_No).numIons;

specificFolder=[ORG_STRUC.homePath, '/', ORG_STRUC.specificFolder];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INCAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[status, msg] = unix(['cat ' specificFolder '/INCAR_' num2str(Step) ' > INCAR']);
if status > 0
    disp(' ');
    disp(msg);
    disp(['No INCAR_' num2str(Step) ' in Specfic directory']);
    quit
end
if ~isempty(ORG_STRUC.ExternalPressure)
    fp = fopen('INCAR', 'a+');
    fprintf(fp, ['\nPSTRESS=' num2str(ORG_STRUC.ExternalPressure*10) '\n']);
    fclose(fp);
    % unixCmd(['echo PSTRESS=' num2str(ORG_STRUC.ExternalPressure*10) '>> INCAR']);
end
%%Sometimes VASP would refuse calculation when symmetry determination
if POP_STRUC.POPULATION(Ind_No).Error >1
    fp = fopen('INCAR', 'a+');
    fprintf(fp, 'ISYM=0\n');
    fclose(fp);

    % unixCmd(['echo ISYM=0 >> INCAR']);
    % coor = perturbCoords(coor, lattice, 1); %Experimental
end
%%% For generating charge densities for last step

if isfield(ORG_STRUC,'optType')
optType   = ORG_STRUC.optType;
if  ~isempty(find(optType == 13))
    if Step == length(ORG_STRUC.abinitioCode)

	[nothing, nothing] = unix('sed -i ''s/LCHARG/#LCHARG/g'' INCAR');
	[nothing, nothing] = unix('sed -i ''s/LAECHG/#LAECHG/g'' INCAR');
	[nothing, nothing] = unix('sed -i ''s/LELF/#LELF/g'' INCAR');

        fp = fopen('INCAR', 'a+');
        fprintf(fp, 'LCHARG = TRUE \n');
        fprintf(fp, 'LAECHG = TRUE \n');
        fprintf(fp, 'LELF = TRUE \n');

        fclose(fp);
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% POTCAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    if ORG_STRUC.varcomp == 1 || ~exist([specificFolder '/POTCAR_' num2str(Step)])  % we prefer this way
        if exist('POTCAR')
            delete('POTCAR');
        end
        N_T = length(ORG_STRUC.atomType);
        for i = 1 : N_T
            if POP_STRUC.POPULATION(Ind_No).numIons(i) > 0
                if ORG_STRUC.atomType(i)==0.5
                    label=['H.5'];
                elseif ORG_STRUC.atomType(i)==0.75
                    label=['H.5'];
                elseif ORG_STRUC.atomType(i)==1.25
                    label=['H1.25'];
                elseif ORG_STRUC.atomType(i)==1.5
                    label=['H1.5'];
                else
                    label= megaDoof(ORG_STRUC.atomType(i));
                end
                if exist([specificFolder '/POTCAR_' label])
                    unixCmd([' cat ' specificFolder '/POTCAR_' label ' >> POTCAR '] );
                else
                    disp(['POTCAR_' label ' is missing in Specific Directory']);
                    disp('USPEX reject this calculation in this case');
                    quit
                end
            end
        end
    else
        unixCmd(['cat ' specificFolder '/POTCAR_' num2str(Step) ' > POTCAR']);
    end
catch
    disp('Insufficient POTCARs in Specific Directory');
    quit
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% POSCAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ORG_STRUC.dimension==2
    Write_POSCAR_surface(Ind_No)
elseif ORG_STRUC.dimension==-3
    writeOUT_POSCAR_GB(Ind_No)
else
    Write_POSCAR(ORG_STRUC.atomType, count, symg, numIons, lattice, coor);   %vasp5-format
    if    POP_STRUC.POPULATION(Ind_No).Step == ORG_STRUC.conv_till+1 ...
       && ORG_STRUC.conv_till < length([ORG_STRUC.abinitioCode]) ...
       && ~isfield(ORG_STRUC,'GaussianHeight')
	if exist('outputPOSCAR')
            copyfile('outputPOSCAR', 'POSCAR');
	end
    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% SPIN MAGMOM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield( ORG_STRUC, 'spin') & (ORG_STRUC.spin == 1)
    fp = fopen('INCAR_spinPart', 'w');
    fprintf(fp,'\n\n');
    
    if isempty ( POP_STRUC.POPULATION(Ind_No).magmom_ini )
        numIons = POP_STRUC.POPULATION(Ind_No).numIons;
        POP_STRUC.POPULATION(Ind_No).magmom_ini=zeros( 1, 1+sum(numIons) );
        POP_STRUC.POPULATION(Ind_No).magmom_ions=zeros( length([ORG_STRUC.abinitioCode]), 1+sum(numIons) );
        POP_STRUC.POPULATION(Ind_No).magmom_ions(1,:) = initialize_magMom(numIons,ORG_STRUC.magRatio);
        POP_STRUC.POPULATION(Ind_No).magmom_ini= POP_STRUC.POPULATION(Ind_No).magmom_ions(1,:);
        POP_STRUC.POPULATION(Ind_No).mag_moment=zeros( 1,length([ORG_STRUC.abinitioCode]) );
    end
    
    ispin = 2;
    if Step <= 3
        fprintf(fp,'LORBIT=11\n');
        fprintf(fp,'ISPIN=%d\n',ispin);
        fprintf(fp,'MAGMOM=');
        fprintf(fp,' %5.3f', POP_STRUC.POPULATION(Ind_No).magmom_ini(1, 2:end) );
    else
        if POP_STRUC.POPULATION(Ind_No).magmom_ions(Step-1,1)==1 %|| sum(abs(POP_STRUC.POPULATION(Ind_No).magmom_ions(Step-1,2:end)))==0
            fprintf(fp,'ISPIN=%d\n',ispin);
            fprintf(fp,'LORBIT=11\n');
        else
            fprintf(fp,'LORBIT=11\n');
            fprintf(fp,'ISPIN=%d\n',ispin);
            fprintf(fp,'MAGMOM=');
            fprintf(fp,' %5.3f', POP_STRUC.POPULATION(Ind_No).magmom_ions(Step-1, 2:end) );
        end
    end
    
    fprintf(fp,'\n');
    
    fclose(fp);
    unixCmd('cat INCAR_spinPart >> INCAR');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% KPOINTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Kpoints, Error] = Kgrid(lattice, ORG_STRUC.Kresol(Step), ORG_STRUC.dimension);
if Error == 1  % This LATTICE is extremely wrong, let's skip it from now
    POP_STRUC.POPULATION(Ind_No).Error = POP_STRUC.POPULATION(Ind_No).Error + 4;
else
    POP_STRUC.POPULATION(Ind_No).K_POINTS(Step,:)=Kpoints;
end

fp = fopen('KPOINTS', 'w');

fprintf(fp,'EA\n');
fprintf(fp,'0\n');
fprintf(fp,'Gamma\n');
fprintf(fp,'%4d %4d %4d\n', Kpoints(1,:));

fclose(fp);

%unixCmd(['cp POSCAR POSCAR-G' num2str(POP_STRUC.generation) '-N' num2str(Ind_No) '-S' num2str(Step)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LDAU %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield( ORG_STRUC, 'ldaU') & sum(norm(ORG_STRUC.ldaU))>0
    fp = fopen('INCAR_LDAUPart', 'w');
    fprintf(fp,'\n\n');
    
    
    ldaUPrint=zeros(3,size(ORG_STRUC.ldaU,2));
    ldaUPrint(1,:)=ORG_STRUC.ldaU(1,:);
    ldaUPrint(2,:)=ORG_STRUC.ldaU(2,:);
    
    for i =1:length(POP_STRUC.POPULATION(Ind_No).numIons)
        if  ORG_STRUC.ldaU(1,i)>0
            ldaUPrint(3,i)= 2;
        else
            ldaUPrint(3,i)=-1;
        end
    end
    isPrint=zeros(1,length(ORG_STRUC.ldaU));
    for i = 1:length(POP_STRUC.POPULATION(Ind_No).numIons)
        isPrint(i)=ORG_STRUC.ldaU(1,i)*POP_STRUC.POPULATION(Ind_No).numIons(i);
    end
    if sum(isPrint)>0
        fprintf(fp,'LDAU=.True.\n');
        fprintf(fp,'LDAUTYPE=2 \n');
        fprintf(fp,'LDAUPRINT =2\n');
        fprintf(fp,'LDAUL= ');
        for i = 1:length(POP_STRUC.POPULATION(Ind_No).numIons)
            if  POP_STRUC.POPULATION(Ind_No).numIons(i) > 0
                fprintf(fp,'%2d ',ldaUPrint(3,i));
            end
        end
        fprintf(fp,'\nLDAUU= ');
        for i = 1:length(POP_STRUC.POPULATION(Ind_No).numIons)
            if  POP_STRUC.POPULATION(Ind_No).numIons(i) > 0
                if ORG_STRUC.ldaU(1,i)>0
                    fprintf(fp,'%4.1f ',ldaUPrint(1,i));
                else
                    fprintf(fp,'%2d ',ldaUPrint(1,i));
                end
            end
        end
        fprintf(fp,'\nLDAUJ= ');
        for i = 1:length(POP_STRUC.POPULATION(Ind_No).numIons)
            if  POP_STRUC.POPULATION(Ind_No).numIons(i) > 0
                if ORG_STRUC.ldaU(1,i)>0
                    fprintf(fp,'%4.1f ',ldaUPrint(2,i));
                else
                    fprintf(fp,'%2d ',ldaUPrint(2,i));
                end
            end
        end
        fprintf(fp,'\n');
        
    end
    
    fclose(fp);
    unixCmd('cat INCAR_LDAUPart >> INCAR');
end
