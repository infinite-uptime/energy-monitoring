%%% NC Code Data Extractor
%%% UC Berkeley - LMAS - Raunak Bhinge & Nishant Biswas (Built on work by Timo Banziger)
%%% 10 July 2014
%% Setup

% Import CNC text file into excel using "Space" as a delimiter
% Make sure no extraneous text is beyond column 7 (G)
% Save file with .xlsx extension in "LOGFILES" folder as per the path shown
% in line 15. Set Beta Version as the root folder for Matlab
clc
clear all
close all

filename = 'pointtestNC';
[~,CNC,~] = xlsread(['Data2\NC Extractor\LOGFILES\' filename '.xlsx']);

%% Scrub Data

%Read text, delete row if it doesn't begin with letter and if it is a dwell
kill = ones(size(CNC,1),1);

for line = 1:size(CNC,1)
     PROGRESS = 100*line/size(CNC,1) %Progress bar for sanity's sake
     if isempty(CNC{line,1}) == 1
         CNC(line,1) = num2cell(NaN);
     else
         text = CNC{line,1};
         if isletter(text(1))==0
             CNC(line,1) = num2cell(NaN);
         end
     end
     if sum(isnan(CNC{line,1}))==1 %|| sum(strcmp(CNC(line,:),'G04')) == 1
         kill(line) = 0;
     end
     clc
end
clear line
clear PROGRESS

CNC(find(kill<1),:) = [];

clear kill
%% Initialize

Pos_X = NaN(size(CNC,1),1);
Pos_Y = NaN(size(CNC,1),1);
Pos_Z = NaN(size(CNC,1),1);
Feed = NaN(size(CNC,1),1);
Speed = NaN(size(CNC,1),1);
modal = NaN(size(CNC,1),1); modal(1)=0;

%% Extract Data
% Special cases:

for line = 1:size(CNC,1)
    for code = 1:7
      text = CNC{line,code};
      l = size(text,2);
      if isempty(text) == 0
        if isempty(strfind(text,'F')) == 0
            Feed(line,1) = str2num(text(2:l));
        elseif isempty(strfind(text,'S')) == 0
            Speed(line,1) = str2num(text(2:l));
        end
        if isempty(strfind(text,'X')) == 0
            Pos_X(line,1) = str2num(text(2:l));
        end
        if isempty(strfind(text,'Y')) == 0
            Pos_Y(line,1) = str2num(text(2:l));
        end
        if isempty(strfind(text,'Z')) == 0
            Pos_Z(line,1) = str2num(text(2:l));
        end
      end
    end
end

%% Modal G-code tracking

for i = 1:size(CNC,1)
    if sum(strcmp(CNC(i,:),'G00')) == 1 || sum(strcmp(CNC(i,:),'G0')) == 1
        modal(i)=0;
    elseif sum(strcmp(CNC(i,:),'G01')) == 1 || sum(strcmp(CNC(i,:),'G1')) == 1
        modal(i)=1;
    elseif sum(strcmp(CNC(i,:),'G02')) == 1 || sum(strcmp(CNC(i,:),'G2')) == 1
        modal(i)=2;
    elseif sum(strcmp(CNC(i,:),'G03')) == 1 || sum(strcmp(CNC(i,:),'G3')) == 1
        modal(i)=3;
    end
end
%% Smooth modal tracking

for i = 2:size(CNC,1)
     if isnan(modal(i)) == 1
        modal(i) = modal(i-1);
     end
end

%% Adjustments and calculations
%  Set X,Y,Z positions if machine is sent home
for i = 1:size(CNC,1)
    if sum(strcmp(CNC(i,:),'G28')) == 1
        for j = 1:7
            text = CNC{i,j};
            l = size(text,2);
            if strcmp(text(1:l),'X0')==1
                Pos_X(i) = 0;
            end
            if strcmp(text(1:l),'Y0')==1
                Pos_Y(i) = 0;
            end
            if strcmp(text(1:l),'Z0')==1
                Pos_Z(i) = 0;
            end
        end
    end
end

 %Smooth X,Y,Z values, acount for dwells on Pos_X 

for i = 2:size(CNC,1)
     if isnan(Pos_X(i)) == 1 || sum(strcmp(CNC(i,:),'G04')) == 1
        Pos_X(i) = Pos_X(i-1);
     end
     if isnan(Pos_Y(i)) == 1
        Pos_Y(i) = Pos_Y(i-1);
     end
     if isnan(Pos_Z(i)) == 1
        Pos_Z(i) = Pos_Z(i-1);
     end
     if isnan(Feed(i)) == 1
        Feed(i) = Feed(i-1);
     end
     if isnan(Speed(i)) == 1
        Speed(i) = Speed(i-1);
     end
end
%Set feeds at dwells to 0
for i = 1:size(CNC,1)
     if  sum(strcmp(CNC(i,:),'G04')) == 1
        Feed(i) = 0;
     end
end

% Length of Cut: dX|dY|Total|dZ
dX(1) = 0;dY(1) = 0; dZ(1) = 0;LoCxy(1) = 0; LoCxyz(1) = 0;  
for i = 2:size(CNC,1)
    dX(i,1) = Pos_X(i)-Pos_X(i-1);%dX
    dY(i,1) = Pos_Y(i)-Pos_Y(i-1);%dY
    dZ(i,1) = Pos_Z(i)-Pos_Z(i-1);%dZ
    LoCxy(i,1) = sqrt(dX(i)^2 + dY(i)^2);
    LoCxyz(i,1) = sqrt(dX(i)^2 + dY(i)^2 + dZ(i)^2);
end

%Add data to cell array
CNC(:,8) = num2cell(Feed);
CNC(:,9) = num2cell(Speed);
CNC(:,10) = num2cell(Pos_X);
CNC(:,11) = num2cell(Pos_Y);
CNC(:,12) = num2cell(Pos_Z);
CNC(:,13) = num2cell(dX);
CNC(:,14) = num2cell(dY);
CNC(:,15) = num2cell(LoCxy);
CNC(:,16) = num2cell(dZ);
CNC(:,17) = num2cell(LoCxyz);
CNC(:,25) = num2cell(modal);

%Add column headers
CNC(2:size(CNC,1)+1,:) = CNC;
CNC{1,1} = 'Code'; CNC{1,2} = 'Code'; CNC{1,3} = 'Code'; CNC{1,4} = 'Code';
CNC{1,5} = 'Code'; CNC{1,6} = 'Code'; CNC{1,7} = 'Code';
CNC{1,8} = 'Feed Rate (mm/min)';
CNC{1,9} = 'Spindle Speed (RPM)';
CNC{1,10} = 'X (mm)';
CNC{1,11} = 'Y (mm)';
CNC{1,12} = 'Z (mm)';
CNC{1,13} = 'dX (mm)';
CNC{1,14} = 'dY (mm)';
CNC{1,15} = 'Length of Cut X-Y (mm)';
CNC{1,16} = 'dZ (mm)';
CNC{1,17} = 'Length of Cut in X-Y-Z (mm)';
CNC{1,25} = 'Modal Code';

clearvars -except CNC filename modal
xlswrite(['All Transformed and Simulated Data/' filename '_Initial.xlsx'],CNC)
NCsimulatecut();