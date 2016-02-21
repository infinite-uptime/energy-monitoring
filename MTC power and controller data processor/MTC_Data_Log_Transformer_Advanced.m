%%% MTC Client Data Log Transformer - Advanced
%%% UC Berkeley - LMAS - Raunak Bhinge & Nishant Biswas (Built on work by Timo Banziger)
%%% 21 April 2014

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Record the MTC data on the computer in the machine shop by opening
% the shortcut 'Ruby Console' on the desktop. Move to directory
% C:/vimana/agent/logs and type the following to start recording:
% 'ruby dump_agent.rb http://localhost:5000/mori_nvd_1500/
% filename.txt'.
%
% Import the textfile in Excel by using 'Tab', 'Space', and '|' as
% separating signs. Delete the first rows of the data until the first set
% of power data and save the Excelfile in 'LOGFILES' of the Matlab
% directory. Put the filename of the Excel file under 'filename' on line
% 30.
%
% The parameters of the matrix 'Data' can be found on line ???(179).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Setup

clc
clear all
close all

for q = 1
filenames = ['6013Part3test';];%'Tool2Test7';'Tool3Test7';'Tool4Test7';'Tool5Test7';'Tool6Test7';'Tool7Test7';'Tool8Test7';'Tool9Test7';];
%filenames = ['Tool10Test1';'Tool10Test2';'Tool10Test3';];
clearvars -except q filenames
filename = filenames(q,:);

CalibrationFactor = 0.0148; %For power data 0.046 for left machine, 0.0148 for right machine!

[log_numbers, log_text, log] = xlsread(['LOGFILES/' filename '.xlsx']);
lineshift=size(log,1)-size(log_numbers,1); %Take data into numbers, text

time_zero = time(log,1); %Transform time from timestamp into absolute seconds
time_end = time(log,size(log,1));
time_log = time_end - time_zero;

%% Initialize

Time = (0:0.01:time_log+0.25)';         % 1, establish time range

Pos_X = NaN(size(Time,1),1);            % 2
Pos_Y = NaN(size(Time,1),1);            % 3
Pos_Z = NaN(size(Time,1),1);            % 4

Load_X = NaN(size(Time,1),1);           % 5
Load_Y = NaN(size(Time,1),1);           % 6
Load_Z = NaN(size(Time,1),1);           % 7
Load_S = NaN(size(Time,1),1);           % 8

Feed = NaN(size(Time,1),1);             % 9

Spindle = NaN(size(Time,1),1);          % 10

PowerA=zeros(size(Time,1),1);
PowerB=zeros(size(Time,1),1);
PowerC=zeros(size(Time,1),1);
P_a = NaN(size(Time,1),1);              % 11
P_b = NaN(size(Time,1),1);              % 12
P_c = NaN(size(Time,1),1);              % 13
Q_a = NaN(size(Time,1),1);              % 14
Q_b = NaN(size(Time,1),1);              % 15
Q_c = NaN(size(Time,1),1);              % 16

Block = NaN(size(Time,1),1);            % 17
modal = NaN(size(Time,1),1); modal(1)=0; % modal g-code tracking

%% Transform Data
%This for loop extracts the the controller and power data and and labels it
%accordingly. * parameters are unused in future code/calculations.

for line = 2:size(log,1)
    
    PROGRESS = 100*line/size(log,1) %Progress bar for sanity's sake
    
    %Block
    if strcmp(log(line,2),'block')
       Block(sample(log,line),1) = Time(line-lineshift,1);
    end
    
    % Position*
    if strcmp(log(line,2),'Xact')
       Pos_X(sample(log,line),1) = log_numbers(line-lineshift,1);
    end
    
    if strcmp(log(line,2),'Yact')
       Pos_Y(sample(log,line),1) = log_numbers(line-lineshift,1);
    end
    
    if strcmp(log(line,2),'Zact')
       Pos_Z(sample(log,line),1) = log_numbers(line-lineshift,1);
    end
    
   
    % Load*
    if strcmp(log(line,2),'Xload')
       Load_X(sample(log,line),1) = log_numbers(line-lineshift,1);
    end
    
    if strcmp(log(line,2),'Yload')
       Load_Y(sample(log,line),1) = log_numbers(line-lineshift,1);
    end
    
    if strcmp(log(line,2),'Zload')
       Load_Z(sample(log,line),1) = log_numbers(line-lineshift,1);
    end
    
    if strcmp(log(line,2),'S1load')
       Load_S(sample(log,line),1) = log_numbers(line-lineshift,1);
    end
    
    
     % Feedrate
     if strcmp(log(line,2),'path_feedrate')
       Feed(sample(log,line),1) = log_numbers(line-lineshift,1);
     end
    
    
     % Spindle Speed
     if strcmp(log(line,2),'S1speed')
       Spindle(sample(log,line),1) = log_numbers(line-lineshift,1);
     end
     

    % Real Power
    if strcmp(log(line,2),'kw_a')
        if strcmp(log(line,3),'UNAVAILABLE')
        else
            for i = 0:24
                P_a(sample(log,line)+i,1) = log_numbers(line-lineshift,1+i);
                PowerA(sample(log,line),1) = PowerA(sample(log,line),1) + log_numbers(line-lineshift,1+i);
            end
        end
    end


    if strcmp(log(line,2),'kw_b')
        if strcmp(log(line,3),'UNAVAILABLE')
        else
            for i = 0:24
                P_b(sample(log,line)+i,1) = log_numbers(line-lineshift,1+i);
                PowerB(sample(log,line),1) = PowerB(sample(log,line),1) + log_numbers(line-lineshift,1+i);
            end
        end
    end


    if strcmp(log(line,2),'kw_c')
        if strcmp(log(line,3),'UNAVAILABLE')
        else
            for i = 0:24
                P_c(sample(log,line)+i,1) = log_numbers(line-lineshift,1+i);
                PowerC(sample(log,line),1) = PowerC(sample(log,line),1) + log_numbers(line-lineshift,1+i);
            end
        end
    end
    
    % Reactive Power*
    if strcmp(log(line,2),'kvar_a')
       for i = 0:24
       Q_a(sample(log,line)+i,1) = log_numbers(line-lineshift,1+i);
       end 
    end


    if strcmp(log(line,2),'kvar_b')
       for i = 0:24
       Q_b(sample(log,line)+i,1) = log_numbers(line-lineshift,1+i);
       end 
    end


    if strcmp(log(line,2),'kvar_c')
       for i = 0:24
       Q_c(sample(log,line)+i,1) = log_numbers(line-lineshift,1+i);
       end 
    end
    
    clc
end

clear i
clear line
clear PROGRESS

%% Complete Data - Data smoothing!

Data = [Time, Pos_X, Pos_Y, Pos_Z, Load_X, Load_Y, Load_Z, Load_S,...
    Feed, Spindle, P_a, P_b, P_c, Q_a, Q_b, Q_c, Block];

% Smooths data over patches with no power, doesn't smooth Block
for c = 1:16                   
    
    for l = 2:size(Data,1)
        
        if isnan(Data(l,c))
        Data(l,c) = Data(l-1,c);
        end
       
    end
end

clear c
clear l

%% Pull NC code for each block in cell array, up to 7 code inputs.

k=0; 
for line = 2:size(log,1)
      if strcmp(log(line,2),'block')
        k=k+1;
         for i =1:7
            BlockCode{k,i} = log{line,i+2};
         end    
      end
end

%% Total energy for each block (sums energy data between each block).
Power=(PowerA+PowerB+PowerC)*0.01*CalibrationFactor;

a = find(Block>0);
for i = 2:size(a,1)
     BlockEnergy(i-1) = sum(Power(a(i-1):a(i)));
end
BlockEnergy = BlockEnergy';
BlockEnergy=[BlockEnergy;0];

%% Find time for each block
BlockTime = Time(find(Block>0));
for i = 2:size(a,1)
BlockTime2(i-1) =  BlockTime(i)-BlockTime(i-1);
end
BlockTime2=BlockTime2';
BlockTime2=[BlockTime2;0];

%% Find feedrate, spindle speed, spindle load, X,Y,Z load for each block
for i = 2:size(a,1)
    BlockFeed(i-1) = mean(Data(a(i-1):a(i),9));
    BlockSpindle(i-1) = mean(Data(a(i-1):a(i),10));
    BlockSLoad(i-1) = mean(Data(a(i-1):a(i),8));
    BlockXLoad(i-1) = mean(Data(a(i-1):a(i),5));
    BlockYLoad(i-1) = mean(Data(a(i-1):a(i),6));
    BlockZLoad(i-1) = mean(Data(a(i-1):a(i),7));
end

BlockFeed = BlockFeed'; BlockFeed = [BlockFeed;0];
BlockSpindle = BlockSpindle'; BlockSpindle = [BlockSpindle;0];
BlockXLoad = BlockXLoad'; BlockXLoad=[BlockXLoad;0];
BlockYLoad = BlockYLoad'; BlockYLoad=[BlockYLoad;0];
BlockZLoad = BlockZLoad'; BlockZLoad=[BlockZLoad;0];
BlockSLoad = BlockSLoad'; BlockSLoad=[BlockSLoad;0];

%% Combine Data [Time|Code|Energy|Block Duration|Feed|Speed]   
EData(:,1) = num2cell(BlockTime);
EData(:,2:8) = BlockCode;
EData(:,9) = num2cell(BlockEnergy);
EData(:,10) = num2cell(BlockTime2);
EData(:,11) = num2cell(BlockFeed);
EData(:,12) = num2cell(BlockSpindle);
EData(:,13) =  num2cell(BlockSLoad);
EData(:,14) =  num2cell(BlockXLoad);
EData(:,15) =  num2cell(BlockYLoad);
EData(:,16) =  num2cell(BlockZLoad);

%% Set small feeds at dwells to 0 - can be commented if necessary
feedlimit=5;

for i = 1:size(a,1)
    if strcmp(EData(i,2),'G04')== 1
        if EData{i,11} < feedlimit
            EData(i,11) = num2cell(0);
        end
    end
end

%% X,Y positions from G-Code (for more info see G-Code spreadsheet)
for i = 1:size(a,1)
    if strcmp(EData(i,2),'G04')== 0
     for j = 2:8
            text = EData{i,j};
            l = size(text,2);
             if strcmp(text(1),'X')==1
                EData(i,17) = num2cell(str2num(text(2:l)));
             end
             if strcmp(text(1),'Y')==1
                EData(i,18) = num2cell(str2num(text(2:l)));
             end
     end
    end   
end


%% Find absolute Z values
for line = 1:size(a,1)
    for j = 2:8
        text = EData{line,j};
        l = size(text,2);
        if strcmp(text(1),'Z') == 1
            EData(line,22) = num2cell(str2num(text(2:l)));
        end
    end
end


%% Find and track modal G-codes (G0 / G01 / G02 / G03)
EData(1,32)=num2cell(0);
for line = 1:size(a,1)
    if isnan(EData{line,11})==0
        if sum(strcmp(EData(line,:),'G00')) == 1 || sum(strcmp(EData(line,:),'G0')) == 1 || EData{line,11}>2000
            EData(line,32) = num2cell(0);
        elseif sum(strcmp(EData(line,:),'G02')) == 1 || sum(strcmp(EData(line,:),'G2')) == 1
            EData(line,32) = num2cell(2);
        elseif sum(strcmp(EData(line,:),'G03')) == 1 || sum(strcmp(EData(line,:),'G3')) == 1
            EData(line,32) = num2cell(3);
        elseif sum(strcmp(EData(line,:),'G01')) == 1 || sum(strcmp(EData(line,:),'G1')) == 1 || EData{line,11}>0
            EData(line,32) = num2cell(1);
        end
    end
end


 %Smooth modal G-code values 
 if isempty(EData{1,32}) == 1
     EData{1,22} = 0;
 end
 
 for i = 2:size(a)
     if isempty(EData{i,32}) == 1
         EData(i,32) = EData(i-1,32);
     end
 end



%% Set X,Y positions if machine is sent home
for i = 1:size(a,1)
    if strcmp(EData(i,3),'G28') == 1
        for j = 2:8
            text = EData{i,j};
            l = size(text,2);
            if strcmp(text(1:l),'X0')==1
                EData(i,17) = num2cell(0);
            end
            if strcmp(text(1:l),'Y0')==1
                EData(i,18) = num2cell(0);
            end
        end
    end
end

%% Smooth X,Y,Z values 
    if isempty(EData{1,22}) == 1
        EData{1,22} = 0;
     end
     if isempty(EData{1,17}) == 1
        EData{1,17} = 0;
     end
     if isempty(EData{1,18}) == 1
        EData{1,18} = 0;
     end
     if isempty(EData{1,19}) == 1
        EData{1,19} = 0;
     end
     if isempty(EData{1,20}) == 1
        EData{1,20} = 0;
     end

for i = 2:size(a)
     if isempty(EData{i,17}) == 1
        EData(i,17) = EData(i-1,17);
     end
     if isempty(EData{i,18}) == 1
        EData(i,18) = EData(i-1,18);
     end
     if isempty(EData{i,22}) == 1
        EData(i,22) = EData(i-1,22);
     end
end

%% dX|dY|Total LOC in X-Y|dZ
for i = 2:size(a)
    EData(i,19) = num2cell(EData{i,17} - EData{i-1,17});%dX
    EData(i,20) = num2cell(EData{i,18} - EData{i-1,18});%dY
    EData(i,21) = num2cell(sqrt(EData{i,19}^2 + EData{i,20}^2));%Length of Cut in X-Y
    EData(i,23) = num2cell(EData{i,22} - EData{i-1,22});%dZ
end
 
%% Write to Excel(filename,EData)
 xlswrite([filename '_alpha.xlsx'],EData);
 save([filename '_variables.mat'],'EData');
 clearvars -except EData filename q modal

 simulatecut();
end

%% Plot power vs time, block instances - uncomment if needed

% figure('units','normalized','position',[0,0,1,1]);
% plot(Data(:,1),Data(:,11:13))
% xlabel('Time [s]','FontSize',26)
% ylabel('Power [W]','FontSize',26)
% set(gca,'FontSize',24)
% str = sprintf('Recorded Data');
% title(str,'FontWeight','bold','FontSize',30)


%% Write each block into separate sheet of xls - uncomment if needed
% a = find(Block>0);
% a = [1;a];
% for i = 2:size(a,1)
%     Sheet = Datap(a(i-1):a(i),:);
%     xlswrite('part9p',Sheet,i-1)
% end

