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
tooldia = 9.525;
r = tooldia/2;

%mesh geometry with mesh size 'ms', determines density of element grid
%tolerance=input('Tolerance?');
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
currentZ = zeros(1,N); %currentZ value used in determining depth of cut
D = zeros(1,N); %'D' variable used in determining if elements were cut
IAoC = zeros(size(CNC,1),1); %Intelligent area of cut
IdX = zeros(size(CNC,1),1); %Inteliigent (only along workpiece) length of cut in x-direction
IdY = zeros(size(CNC,1),1); %Intelligent length of cut in y-direction
%Depth = NaN(size(a,1),1); %Should not be needed!!!
CNC(:,18:24) = num2cell(NaN(size(CNC,1),7));
modal = CNC(:,25);
%% get co-ordinates for each corner of each element assuming origin of
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
%% Addition to CNC: Depth of Cut, Strategy of Cut, Intelligent Length of Cut
for i = 2:size(CNC,1)
%for i = 195:250

    PROGRESS2 = 100*i/size(CNC,1) %Progress bar for sanity
    count = 1; %Initialize count (for determining #elements cut)
    count2 = 0; %Initialize count2 (also takes depth into account)
    flag = 0; %Initialize flag, determines if area was cut to new depth
    in = zeros(1,N); %Counts elements within rectangle of tool motion
    in1 = zeros(1,N); %Counts elements also within circular extent of tool (final)
    in2 = zeros(1,N); %Discounts elements within circular extent of tool (initial)
    R = 0; L =0; T =0; B=0; %Initialize counters for cutting strategy and radius of cut
        Xprev=CNC{i-1,10}; %Previous X coordinate of tool
        Yprev=CNC{i-1,11}; %Previous Y coordinate of tool
        Xnew=CNC{i,10}; %Current X coordinate of tool at finish of block
        Ynew=CNC{i,11}; %Current X coordinate of tool at finish of block
        Zvalue=CNC{i,12}; %Current Z coordinate of tool *not completely fixed
        LoC(i) = CNC{i,15};
        
    if CNC{i,13} ~=0 && isnan(CNC{i,13})==0 && modal{i}~=0 || CNC{i,14}~=0 && isnan(CNC{i,14})==0 && modal{i}~=0 || sum(strcmp(CNC(i,:),'G83')) == 1 || modal{i}==2 || modal{i}==3 %If the tool moved or drilled or circled
        if sum(strcmp(CNC(i,:),'G04')) == 0 && sum(strcmp(CNC(i,2),'G4')) == 0  && sum(strcmp(CNC(i,:),'G00')) == 0 && sum(strcmp(CNC(i,2),'G0')) == 0 %No dwells/rapids        
            if modal{i}~=2 && modal{i}~=3 && sum(strcmp(CNC(i,:),'G73')) == 0 &&sum(strcmp(CNC(i,:),'G83')) == 0 %Linear cuts
        getcorners(); %Function to plot bounds of tool path
        removematerial(); %Function to determine elements within tool path being cut and cutting strategy
          if isnan(mode(D(find(D>0))')) == 1
        Depth(i) = 0;
          else
        Depth(i)= mode(D(find(D>0))');
          end
        
          elseif modal{i}==2 || modal{i}==3 %Circular Cuts
                for code = 1:7
                          text = CNC{i,code};
                          l = size(text,2);
                    if isempty(strfind(text,'J')) == 0 || isempty(strfind(text,'I')) == 0
                            RCheck = 0;
                    elseif isempty(strfind(text,'R')) == 0
                            RCheck = 1;
                            R = str2num(text(2:l));
                    else
                        RCheck = 2;
                    end
                end
                
                if RCheck==1
                    getcircleR_NC();
                elseif RCheck==0;
                    getcircleIJK_NC();
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
            CNC{i,19} = 'Climb';
        elseif B-T>tol
            CNC{i,19} = 'Conventional';
        else
            CNC{i,19} = 'Both';
        end
    else
        Depth(i) =  0;
    end
    
        if flag == 1 %If a cut occured, then area of cut is proportional to #elements within cut (count 2)
        IAoC(i) = count2*(ms^2); % Area of Cut
        IdX(i) = range(Cx(cut2));  % Intelligent dX
        IdY(i) = range(Cy(cut2)); % Intelligent dY
        end
        
    if sum(strcmp(CNC(i,:),'G83')) == 1 || sum(strcmp(CNC(i,:),'G73')) == 1 %if there was a drill
        for code = 1:7
            text = CNC{i,code};
            l = size(text,2);
            if isempty(strfind(text,'Q')) == 0
                Depth(i) = str2num(text(2:l)); % Peck Depth
            elseif isempty(strfind(text,'R')) == 0
                ReturnHeight = str2num(text(2:l)); %Return height for if G99
            end
        end

        if sum(strcmp(CNC(i,:),'G83')) == 1 %G83 canned drilling cycle
            CNC{i,16} = CNC{i,12}-ReturnHeight;
            LoC(i) = 8; %hardcoded for now since Z retract not registered!Should we change CNC{i,22} here with the retracted Z value?
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
    
    if sum(strcmp(CNC(i,:),'G83')) ~= 1 % TLoC for drilling already defined
        TLoC(i)=sqrt(LoC(i)^2+CNC{i,16}^2);
    end
        
    if CNC{i,13}==0 && CNC{i,14}==0 && CNC{i,16} < 0 && sum(strcmp(CNC(i,:),'G83')) ~= 1 && sum(strcmp(CNC(i,:),'G73')) ~= 1 && modal{i}~=2 && modal{i}~=3 %If and only if it is a plunge
    getZcut();
    end
        
%Assign calculated values into CNC cell
     CNC{i,18} = Depth(i);    
     CNC{i,15} = LoC(i);     
     CNC{i,20} = IdX(i);
     CNC{i,21} = IdY(i);
     CNC{i,22} = IAoC(i);
     CNC{i,23} = abs(CNC{i,22}*CNC{i,18}); %Area * Depth = Volume of Cut
     
     if sum(strcmp(CNC(i,:),'G83')) == 1 || sum(strcmp(CNC(i,:),'G73')) == 1 %Volume of cut defined differently for drilling
         CNC{i,23} = abs(CNC{i,22}*CNC{i,16}); %Should change to dZ if get proper retract?
     end
     
    if sum(strcmp(CNC(i,:),'G04')) == 1
        CNC{i,24} = 'Dwell';
    %elseif CNC{i,23} > 0 && modal{i}==0
    %    CNC{i,24} = 'Rapid Cut';
    %    disp('Rapid cut detected!');
    elseif CNC{i,23} > 0 && modal{i}~=0
        CNC{i,24} = 'Cut with Feed';
    elseif modal{i}==0 && CNC{i,13} ~=0 || modal{i}==0 && CNC{i,14} ~=0 || modal{i}==0 && CNC{i,16} ~=0
        CNC{i,24} = 'No Cut - Rapid motion';
    elseif modal{i}==1 && CNC{i,13} ~=0 || modal{i}==1 && CNC{i,14} ~=0 || modal{i}==2 && CNC{i,13} ~=0 && CNC{i,14} ~=0 || modal{i}==3 && CNC{i,13} ~=0 && CNC{i,14} ~=0
        CNC{i,24} = 'Air-Cut';
    elseif modal{i}==1 && CNC{i,16}>0
        CNC{i,24} = 'Air-cut in Z while retracting';
    elseif modal{i}==0 && CNC{i,16}>0
        CNC{i,24} = 'Rapid retract';
    end
     
    if modal{i}==1 && CNC{i,16}<0 && CNC{i,23} > 0
        CNC{i,24} = 'Plunge with feed';
    elseif modal{i}==1 && CNC{i,16}<0 && CNC{i,23} == 0
        CNC{i,24}= 'Air-Cut in Z while plunging';
    end
    
     CNC{i,17} = TLoC(i); %Length of cut in X-Y-Z
     clear RCheck
     
%Show cuts occuring on plot only if entire contour is not uniform
if max(max(currentZ))~=min(min(currentZ))
        F=reshape(currentZ,breadthelements,lengthelements);
        figure(1)
        contourf(F',4)
        axis equal
        axis([0 635 0 635])
end
clc
end

%% Write CNC to .xls

CNC{1,18} = 'Depth of Cut';
CNC{1,19} = 'Strategy';
CNC{1,20} = 'IdX';
CNC{1,21} = 'IdY';
CNC{1,22} = 'IAoC';
CNC{1,23} = 'Volume of Cut';
CNC{1,24} = 'Cut / No cut';
clearvars -except CNC filename
xlswrite(['All Transformed and Simulated Data/'  filename '_Final.xlsx'],CNC) %Write to Excel file, specify filename in first input