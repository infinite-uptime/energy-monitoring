%%%Simulate the cutting process in order to calculate the depth of cut for
%%%each block and to find out if each block is climb milling or
%%%conventional milling!
%% Dimensions, Elements
%Get stock dimensions (ASSUMPTION: Workpiece origin is at the center, Workpiece is a rectangle)
% 
% length=input('What is the length of the workpiece in X?');
% breadth=input('What is the length of the workpiece in Y?');
% height=input('What is the height of the workpiece in Z?');

length = 63.5;
breadth = 63.5;
height = 56;

%Get Tool dimensions
%tooldia=input('What is the diameter of the tool?');
tooldia = 6.35;
r = tooldia/2;

%% Meshing the workpiece

%mesh geometry with mesh size 'ms', determines density of element grid
%tolerance=input('Tolerance?'); Tolerance for determining climb vs
%conventional
ms=0.1;
tolerance = .1;
%Calculate number of elements in each direction
lengthelements=length/ms;
breadthelements=breadth/ms;
N = lengthelements*breadthelements; %Total number of elements

%% Preallocation of variables

row = zeros(1,N);
column = zeros(1,N);
LBx = zeros(1,N); %Left bottom x coordinate of element square
LBy = zeros(1,N); %Left bottom y coordinate of element square
RBx = zeros(1,N); %Right botttom x
RBy = zeros(1,N); %Right bottom y
LTx = zeros(1,N); %Left top x
LTy = zeros(1,N); %Left top y
RTx = zeros(1,N); %Right top x
RTy = zeros(1,N); %Right top y
Cx = zeros(1,N); %X coordinate of center of element
Cy = zeros(1,N); %Y coordinate of center of element
D = zeros(1,N); %'D' variable used in determining if elements were cut
IAoC = zeros(size(EData,1),1); %Intelligent area of cut
IdX = zeros(size(EData,1),1); %Inteliigent (only along workpiece) length of cut in x-direction
IdY = zeros(size(EData,1),1); %Intelligent length of cut in y-direction
%Depth = NaN(size(a,1),1); %Should not be needed!!!
EData(:,24:31) = num2cell(NaN(size(EData,1),8));

%% Get co-ordinates for each corner of each element assuming origin of
%workpiece in the center! Left/Right, Top/Bottom, C = center
for element=1:N
        row(element)=1+floor((element-0.5)/lengthelements);
        column(element)=rem((element-1),lengthelements)+1;
        LBx(element)=-(length/2)+(column(element)-1)*ms;
        LBy(element)=-(breadth/2)+(row(element)-1)*ms;
        RBx(element)=LBx(element)+ms;
        RBy(element)=LBy(element);
        LTx(element)=LBx(element);
        LTy(element)=LBy(element)+ms;
        RTx(element)=RBx(element);
        RTy(element)=LTy(element);
        Cx(element) = .5*(LTx(element)+RBx(element));
        Cy(element) = .5*(LTy(element)+RBy(element));
end

%% Define initial geometry
currentZ = zeros(1,N); %currentZ value used in determining depth of cut - assuming a solid block

% for e=1:N
%     if Cx(e)>-10 && Cx(e)<10 && Cy(e)>0
%         currentZ(e)=-20;
%     elseif Cx(e)>-5 && Cx(e)<5 && Cy(e)<0
%         currentZ(e)=-20;
%     else currentZ(e)=0;
%     end
% end
 
%% Addition to EData: Depth of Cut, Strategy of Cut, Intelligent Length of Cut
for i = 2:size(EData,1)
%for i = 195:250

    PROGRESS2 = 100*i/size(EData,1) %Progress bar for sanity
    count = 1; %Initialize count (for determining #elements cut)
    count2 = 0; %Initialize count2 (also takes depth into account)
    flag = 0; %Initialize flag, determines if area was cut to new depth
    in = zeros(1,N); %Counts elements within rectangle of tool motion
    in1 = zeros(1,N); %Counts elements also within circular extent of tool (final)
    in2 = zeros(1,N); %Discounts elements within circular extent of tool (initial)
    R = 0; L =0; T =0; B=0; %Initialize counters for cutting strategy and radius of cut
    RCheck=2; %Initialize RCheck
        Xprev=EData{i-1,17}; %Previous X coordinate of tool
        Yprev=EData{i-1,18}; %Previous Y coordinate of tool
        Xnew=EData{i,17}; %Current X coordinate of tool at finish of block
        Ynew=EData{i,18}; %Current X coordinate of tool at finish of block
        Zvalue=EData{i,22}; %Current Z coordinate of tool *not completely fixed
        LoC(i) = EData{i,21};
        
    if isempty(EData{i,32})==1
        EData(i,32)=0;
    end
        
    if EData{i,19} ~=0 || EData{i,20}~=0 || sum(strcmp(EData(i,:),'G83')) == 1 || sum(strcmp(EData(i,:),'G73')) == 1 || sum(strcmp(EData(i,:),'G02')) == 1 || sum(strcmp(EData(i,:),'G03')) == 1 || sum(strcmp(EData(i,:),'G2')) == 1 || sum(strcmp(EData(i,:),'G3')) == 1 %If the tool moved or drilled or circled
        if sum(strcmp(EData(i,:),'G04')) == 0 && sum(strcmp(EData(i,2),'G4')) == 0  && sum(strcmp(EData(i,:),'G00')) == 0 && sum(strcmp(EData(i,2),'G0')) == 0 %No dwells/rapids        
            if sum(strcmp(EData(i,:),'G02')) == 0 && sum(strcmp(EData(i,:),'G03')) == 0 && sum(strcmp(EData(i,:),'G2')) == 0 && sum(strcmp(EData(i,:),'G3')) == 0 && sum(strcmp(EData(i,:),'G73')) == 0 &&sum(strcmp(EData(i,:),'G83')) == 0 %Linear cuts
        getcorners(); %Function to plot bounds of tool path
        removematerial(); %Function to determine elements within tool path being cut and cutting strategy
          if isnan(mode(D(find(D>0))')) == 1
        Depth(i) = 0;
          else
        Depth(i)= mode(D(find(D>0))');
          end
        
          elseif sum(strcmp(EData(i,:),'G02')) == 1 || sum(strcmp(EData(i,:),'G03')) == 1 || sum(strcmp(EData(i,:),'G2')) == 1 || sum(strcmp(EData(i,:),'G3')) == 1 %Circular Cuts
                for code = 2:8
                          text = EData{i,code};
                          l = size(text,2);
                    if isempty(strfind(text,'J')) == 0 || isempty(strfind(text,'I')) == 0
                            RCheck = 0;
                    elseif isempty(strfind(text,'R')) == 0
                            RCheck = 1;
                            R = str2num(text(2:l));
                    end
                end
                
                if RCheck>0
                    getcircleR();
                elseif RCheck==0;
                    getcircleIJK();
                end
        
        if isnan(mode(D(find(D>0))')) == 1
        Depth(i) = 0;
        else
        Depth(i)= mode(D(find(D>0))');
        end
           
            else
                Depth(i) = 0;
            end
            
tol = tolerance*count2;     
        if T-B>tol % See bottom portion of remove material
            EData{i,24} = 'Climb';
        elseif B-T>tol
            EData{i,24} = 'Conventional';
        else
            EData{i,24} = 'Both';
        end
    else
        Depth(i) =  0;
    end
    
        if flag == 1 %If a cut occured, then area of cut is proportional to #elements within cut (count 2)
        IAoC(i) = count2*(ms^2); % Area of Cut
        IdX(i) = range(Cx(cut2));  % Intelligent dX
        IdY(i) = range(Cy(cut2)); % Intelligent dY
        end
        
    if sum(strcmp(EData(i,:),'G83')) == 1 || sum(strcmp(EData(i,:),'G73')) == 1
        for code = 2:8
            text = EData{i,code};
            l = size(text,2);
            if isempty(strfind(text,'Q')) == 0
                Depth(i) = str2num(text(2:l)); % Peck Depth
            elseif isempty(strfind(text,'R')) == 0
                ReturnHeight = str2num(text(2:l)); %Return height for if G99
            end
        end

        if sum(strcmp(EData(i,:),'G83')) == 1 %G83 canned drilling cycle
            EData{i,23} = EData{i,22}-ReturnHeight;
            LoC(i) = 8; %hardcoded for now since Z retract not registered!Should we change EData{i,22} here with the retracted Z value?
            IdX(i) = 0; %IdX
            IdY(i) = 0; %IdY
            IAoC(i) = pi*r^2; %Area
            TLoC(i) = LoC(i);%Total Length of cut % Simulate similar to a plunge for depth of cut
            %else for G73?
        end
    end
         
    clear cut
    clear cut2
   
    
    %Else If a spiral is detected (dX=0,dY=0 but G02/G2/G03/G3 & I/J/K, then
    %getspiralIJK, if dX=0,dY=0 but G02/G2/G03/G3 & R, then getspiralR

    else
        Depth(i)=0;
    end
    
    if sum(strcmp(EData(i,:),'G83')) ~= 1 % TLoC for drilling already defined
        TLoC(i)=sqrt(LoC(i)^2+EData{i,23}^2);
    end
        
    if EData{i,23} < 0 && sum(strcmp(EData(i,:),'G83')) ~= 1 && sum(strcmp(EData(i,:),'G73')) ~= 1 && RCheck==2 %If and only if it is a plunge
    getZcut();
    end
        
%% Assign calculated values into EData cell
     EData{i,27} = Depth(i);    
     EData{i,21} = LoC(i);     
     EData{i,25} = IdX(i);
     EData{i,26} = IdY(i);
     EData{i,28} = IAoC(i);
     EData{i,29} = abs(EData{i,28}*EData{i,27}); %Area * Depth = Volume of Cut
     
     if sum(strcmp(EData(i,:),'G83')) == 1 || sum(strcmp(EData(i,:),'G73')) == 1 %Volume of cut defined differently for drilling
         EData{i,29} = abs(EData{i,28}*EData{i,21}); %Should change to dZ if get proper retract?
     end
     
%% Detect tye of cut for easy classification

    if sum(strcmp(EData(i,:),'G04')) == 1
        EData{i,30} = 'Dwell';
    %elseif EData{i,23} > 0 && modal{i}==0
    %    EData{i,24} = 'Rapid Cut';
    %    disp('Rapid cut detected!');
    elseif EData{i,29} > 0 && EData{i,32}~=0
        EData{i,30} = 'Cut with Feed';
    elseif EData{i,32}==0 && EData{i,19} ~=0 || EData{i,32}==0 && EData{i,20} ~=0 || EData{i,32}==0 && EData{i,23} ~=0
        EData{i,30} = 'No Cut - Rapid motion';
    elseif EData{i,32}==1 && EData{i,19} ~=0 || EData{i,32}==1 && EData{i,20} ~=0 || EData{i,32}==2 && EData{i,19} ~=0 && EData{i,20} ~=0 || EData{i,32}==3 && EData{i,19} ~=0 && EData{i,20} ~=0
        EData{i,30} = 'Air-Cut';
    elseif EData{i,32}==1 && EData{i,23}>0
        EData{i,30} = 'Air-cut in Z while retracting';
    elseif EData{i,32}==0 && EData{i,23}>0
        EData{i,30} = 'Rapid retract';
    end
     
    if EData{i,32}==1 && EData{i,23}<0 && EData{i,29} > 0
        EData{i,30} = 'Plunge with feed';
    elseif EData{i,32}==1 && EData{i,23}<0 && EData{i,29} == 0
        EData{i,30}= 'Air-Cut in Z while plunging';
    end
     
     EData{i,31} = TLoC(i); %Length of cut in X-Y-Z
     clear RCheck
     
%Show cuts occuring on plot only if entire contour is not uniform
% if max(max(currentZ))~=min(min(currentZ))
%         F=reshape(currentZ,breadthelements,lengthelements);
%         figure(1)
%         contourf(F',4)
%         axis equal
%         axis([0 635 0 635])
% end

clc
end

%% Write EData to .xls
firstrow = num2cell(zeros(1,size(EData,2))); %Free first row for column headers
EData = cat(1,firstrow,EData);
EData{1,1} = 'Timestamp (s)'; %See MTC_Data_Log_Transformer for cols 1-18
EData{1,2} = 'Code';
EData{1,3} = 'Code';
EData{1,4} = 'Code';
EData{1,5} = 'Code';
EData{1,6} = 'Code';
EData{1,7} = 'Code';
EData{1,8} = 'Code';
EData{1,9} = 'Energy (J)';
EData{1,10} = 'Duration (s)';
EData{1,11} = 'Feed rate (mm/min)';
EData{1,12} = 'Spindle speed (RPM)';
EData{1,13} = 'Spindle Load';
EData{1,14} = 'X Load';
EData{1,15} = 'Y Load';
EData{1,16} = 'Z Load';
EData{1,17} = 'X (mm)';
EData{1,18} = 'Y (mm)';
EData{1,19} = 'dX (code) (mm)';
EData{1,20} = 'dY (code) (mm)';
EData{1,21} = 'Length of Cut XY (code) (mm)';
EData{1,22} = 'Z (mm)';
EData{1,23} = 'dZ (mm)';
EData{1,24} = 'Cutting Strategy'; %Climb/Conventional/Both
EData{1,25} = 'IdX (mm)';
EData{1,26} = 'IdY (mm)';
EData{1,27} = 'Depth of Cut(mm)';
EData{1,28} = 'Area of Cut (mm^2)';
EData{1,29} = 'Volume of Cut (mm^3)';
EData{1,30} = 'Cut / No Cut';
EData{1,31} = 'Length of Cut XYZ (code) (mm)';
EData{1,32} = 'Modal G-Code';
xlswrite([filename '_beta.xlsx'],EData) %Write to Excel file, specify filename in first input