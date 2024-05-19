function smb_tirM_pick_Cy5Cy7
% Single Molecule Biophysics Lab. in Seoul National University // MJ 2019 July
% last edited by X. Feng Aug 18, 2022

clear all;
close all;

%% path and filename setting
WorkingDirectory=pwd
filename_head = 'your_trace_name_header'; % for example 'hel3'

%% Correction parameters for FRET%%
dbackground_b=-50;
d2background_b=0;
abackground_b=0;


dbackground_g=0;
d2background_g=0;
abackground_g=0;

dbackground_r=0;
d2background_r=0;
abackground_r=0;

% The following parameters (leakage, gamma, direct) are custom to Ha Lab 
% 310D microscope
% Change them for your microscope

leakage12=0.1066;   
leakage21=0.0;
leakage13=0.0083;  
leakage23=0.0446;  

gamma12=0.8730; 
gamma23 = 2.62;
gamma13=gamma12*gamma23;

direct = 0.12; 

%% Options
LaserOrderChange = 'y'; %Check this part when excitation laser order is matched.
ColorNumber = 3;
DyeType = 'cy235';      %not done: b->g, g->r, r->far red (color change only)
DoseBinningNeed = 'n';  %binning required??
binwidth=5;
DoesFilterNeed = 'n';   %filter required??
DoseMovieNeed = 'n';    % Movie required??
Is_Avg_and_E_save ='n'; % Average and E level save??
Time_unit_ms = 'n';     % Time unit is 'ms'?
FirstNumber = 50;       % histogram options
LastNumber = 10;        % histogram options

%% Trace axis range
BottomLimit_b=-100;
UpperLimit_b=1500;
BottomLimit_g=-100;
UpperLimit_g=1500;
BottomLimit_r=-100;
UpperLimit_r=1500;

%% log file loading (time unit etc. Ha lab ver.)

fileinfo = dir([filename_head '.log']);
if sum(size(fileinfo)) == 1
    disp(['No log file : '  filename_head '.log']);
end
%date = fileinfo(1).date;
fileid_log = fopen([filename_head '.log'],'r');		%% .log file
logarray = textscan(fileid_log, '%s', 'Delimiter','\n');
timeunit = 0.001*str2double(logarray{1,1}{strmatch('Exposure Time [ms]', logarray{1,1})+1})
gain = str2double(logarray{1,1}{strmatch('Gain', logarray{1,1})+1})
scaler = str2double(logarray{1,1}{strmatch('Data Scaler', logarray{1,1})+1})
background_donor = str2double(logarray{1,1}{strmatch('Background', logarray{1,1})+1})
background_acceptor = str2double(logarray{1,1}{strmatch('Background', logarray{1,1})+1})
fclose(fileid_log);

%% path and filename

OriginalDirectory=cd;
cd(WorkingDirectory);
filename_traces = [filename_head '.' num2str(ColorNumber) 'color_3alex_traces'];
filename_movie = [filename_head '.' num2str(ColorNumber) 'color_3alex_movies'];
filename_time = [filename_head '_time.dat'];
filename_add = [ filename_head '_select.dat'];
filename_add_region = [ filename_head '_region.dat' ];
filename_add_region_data=[ filename_head '_region_data.dat' ];

%% Reading data %%
fileid = fopen(filename_traces,'r');

if fileid == -1
    disp(['No data file  '  filename_head]);
end

time_length = fread(fileid, 1, 'int32');
disp(sprintf('The length of the time traces is: %d', time_length));

time = (0:(time_length-1))*timeunit;

NumberofTraces = fread(fileid, 1, 'int16');
NumberofPeaks = NumberofTraces/ColorNumber;
disp('The number of traces and peaks are:')
disp(NumberofTraces);
disp(NumberofPeaks);
%Data = zeros(NumberofTraces, time_length, 'int16');
Data = fread(fileid, [NumberofTraces  time_length],'int16');
SpotDiameter = fread(fileid, 1, 'int16');
disp('Done reading trace data.');
fclose(fileid);

Temp_i = [];
Tempfirstpoint = [];
Templastpoint = [];
Templength = [];
Temptime_region = [];
TempFret12_region = [];
TempFret13_region = [];
TempFret23_region = [];
TempDonor_b_region = [];
TempDonor2_b_region = [];
TempAcceptor_b_region = [];
TempDonor_g_region = [];
TempDonor2_g_region = [];
TempAcceptor_g_region = [];
TempDonor_r_region = [];
TempDonor2_r_region = [];
TempAcceptor_r_region = [];

fileid_add_region = fopen(filename_add_region, 'r');
%fileid_add_region_data = fopen(filename_add_region_data, 'r');
fileid_add_region_data = -1;
if fileid_add_region~=-1 && fileid_add_region_data~=-1;
    fgetl(fileid_add_region);
    temp = fscanf(fileid_add_region, '%f %f %f  %f %f %f  %f %f %f  %f %f %f %f  %f %f  %f\n', [13 1]);
    
    dbackground_b=double(temp(1,1));
    d2background_b=double(temp(2,1));
    abackground_b=double(temp(3,1));
    
    dbackground_g=double(temp(4,1));
    d2background_g=double(temp(5,1));
    abackground_g=double(temp(6,1));
    
    dbackground_r=double(temp(7,1));
    d2background_r=double(temp(8,1));
    abackground_r=double(temp(9,1));
    
    leakage12=double(temp(10,1));   %0.11
    leakage21=double(temp(11,1));
    leakage13=double(temp(12,1));   %0.013
    leakage23=double(temp(13,1));   %0.12
    
    gamma12=double(temp(14,1));  %1
    gamma13=double(temp(15,1));  %2.36
    
    direct=double(temp(16,1));   %0.19
    
    fgetl(fileid_add_region);
    temp = fscanf(fileid_add_region, '%f %f %f %f\n', [4 inf]);
    Temp_i = int32(temp(1,:));
    Tempfirstpoint = int32(temp(2,:));
    Templastpoint = int32(temp(3,:));
    Templength = int32(temp(4,:));
    
    temp = fscanf(fileid_add_region_data, '%f %f %f %f  %f %f %f  %f %f %f  %f %f %f\n', [10 inf]);
    Temptime_region = temp(1,:);
    TempFret12_region = temp(2,:);
    TempFret13_region = temp(3,:);
    TempFret23_region = temp(4,:);
    TempDonor_b_region = temp(5,:);
    TempDonor2_b_region = temp(6,:);
    TempAcceptor_b_region = temp(7,:);
    TempDonor_g_region = temp(8,:);
    TempDonor2_g_region = temp(9,:);
    TempAcceptor_g_region = temp(10,:);
    TempDonor_r_region = temp(11,:);
    TempDonor2_r_region = temp(12,:);
    TempAcceptor_r_region = temp(13,:);
    fclose(fileid_add_region);
    fclose(fileid_add_region_data);
end


if DoseMovieNeed == 'y'
    cd(WorkingDirectory);
    disp(filename_movie);
    fileid_movie = fopen(filename_movie, 'r');
    if fileid_movie ~= -1
        peaks_total_width = fread(fileid_movie, 1, 'int16');
        peak_height = fread(fileid_movie, 1, 'int16');
        peaks_number = peaks_total_width/peak_height;
        file_information = dir(filename_movie);
        film_time_length = (file_information.bytes-4)/(peak_height*peaks_total_width);
        fclose(fileid_movie);
        
        disp('peaks_total_width, height, number, film_time_length: ');
        disp(peaks_total_width);
        disp(peak_height);
        disp(peaks_number);
        disp(film_time_length);
        
        peak_line=zeros(ColorNumber*peak_height, 1, 'uint8');
        %%peaks=fread(fileid_movie, peaks_total_width * peak_height * film_time_length, 'uint8');
        peak=zeros(ColorNumber*peak_height, peak_height, 'uint8');
        
        if peaks_number ~= NumberofTraces
            disp('error: Different trace numbers between .trace and .movies');
            return;
        end
        
        if film_time_length ~= time_length
            disp('error: Different time length between .trace and .movies');
            return;
        end
    else
        DoseMovieNeed = 'n';
        disp('No movie file');
    end
end



%% Convert raw data into donor and acceptor traces %%
time_length_each = time_length;

DonorRawData = zeros(NumberofPeaks, time_length_each, 'double');
Donor2RawData = zeros(NumberofPeaks, time_length_each, 'double');
AcceptorRawData = zeros(NumberofPeaks, time_length_each, 'double');

binlength = int32(time_length/binwidth-1);
bintime = zeros(binlength, 1, 'double');
binEraw = zeros(binlength, 1, 'double');
binEcorrect = zeros(binlength, 1, 'double');


for m=1:binlength
    bintime(m) = double(m-1)*(binwidth*timeunit);
end



for i = 1:NumberofPeaks
    
    DonorRawData(i, :) = Data(i*3-2, :);
    Donor2RawData(i, :) = Data(i*3-1, :);
    AcceptorRawData(i, :) = Data(i*3, :);
    
end


clear Data;



%% calculate, plot and save average traces %%
%MJ edited
% �� trace�� average�� ������, ù��° laser excitation�� Cy3 channel(����)�� �ι�° laser
%excitation�� cy3 channel�� ���� ��, ū ���� trace�� green laser excitation���� ���� ����
%trace�� red laser excitation���� ����
DonorRawData_b = DonorRawData;
Donor2RawData_b = Donor2RawData;
AcceptorRawData_b = AcceptorRawData;


%% Start to servey
Temptime = [];
%TempFret = [];
%TempDonor = [];
%TempAcceptor = [];
TempFret12 = [];
TempFret13 = [];
TempFret23 = [];
TempDonor_b = [];
TempDonor2_b = [];
TempAcceptor_b = [];
TempDonor_g = [];
TempDonor2_g = [];
TempAcceptor_g = [];
TempDonor_r = [];
TempDonor2_r= [];
TempAcceptor_r = [];
r12_list = [];
r13_list = [];
r23_list = [];
l12_list = [];
l13_list = [];
l23_list = [];
dd2ac_list = [];
t_list = -1 * ones(NumberofPeaks, 1);
DT1=[];DT2=[];DT3=[];
DT1start = [];
DT1end = [];
% DT1a=[];DT2a=[];DT3a=[];
% DT1d=[];DT2d=[];DT3d=[];
% DT1f=[];DT2f=[];DT3f=[];
DT1id = [];

scrsz = get(0,'ScreenSize');
figure('Name','Trace analysis','OuterPosition',[scrsz(4)*0.1 0.4*scrsz(4) scrsz(4)*1.5 0.4*scrsz(4)]);

i=0;
history_n = 0;
history = zeros(1000, 1, 'int16');
is_junk = zeros(NumberofPeaks, 1);

% Display traces

while i < NumberofPeaks
    i = int32(int32(i) + 1);
    
    again=1;
    while ((again==1) && (i <= NumberofPeaks))
        if ColorNumber == 3
            if DyeType == 'cy235'
                DonorCorrect_b = ((1 + leakage12 + leakage13) / (1 - leakage12 * leakage21)) * ((DonorRawData_b(i,:) - dbackground_b) - leakage21 * (DonorRawData_b(i,:) - d2background_b));
                Donor2Correct_b = gamma12 * ((1 + leakage21 + leakage23) / (1 - leakage12 * leakage21)) * ((Donor2RawData_b(i,:) - d2background_b) - leakage12 * (DonorRawData_b(i,:) - dbackground_b));
                AcceptorCorrect_b = gamma13 * ((AcceptorRawData_b(i,:) - abackground_b) - ((leakage23 * leakage12 - leakage13)/(1 - leakage12 * leakage21)) * (DonorRawData_b(i,:) - dbackground_b) + ((leakage13 * leakage21 - leakage23 ) / (1 - leakage12 * leakage21)) * (Donor2RawData_b(i,:) -d2background_b));
                EachTotalCorrect_b = DonorCorrect_b + Donor2Correct_b + AcceptorCorrect_b;
                EachTotalCorrect_b = (EachTotalCorrect_b~=0).*EachTotalCorrect_b + (EachTotalCorrect_b==0)*1;	% remove zeros
                
                Fret23 = zeros(1, time_length_each, 'double');
                Fret12 = Donor2Correct_b./((1-Fret23).*DonorCorrect_b + Donor2Correct_b);
                Fret13 = (AcceptorCorrect_b - Fret23.*(Donor2Correct_b + AcceptorCorrect_b))./(DonorCorrect_b + AcceptorCorrect_b - Fret23 .* (EachTotalCorrect_b));
            end
        end
        
        
        
        for j=2:time_length_each
            if (Fret13(j) < -0.3)
                Fret13(j) = 0;
            elseif (Fret13(j) > 1.1)
                Fret13(j) = 1;
            end
            if(Fret12(j) < -0.3)
                Fret12(j) = 0;
            elseif(Fret12(j) > 1.1)
                Fret12(j) = 1;
            end
            if(Fret23(j) < -0.3)
                Fret23(j) = 0;
            elseif(Fret23(j) > 1.1)
                Fret23(j) = 1;
            end
        end
        
        
        
        again=0;
        %end
        %i = i + 1 ;
    end
    plot( time, Donor2Correct_b, 'r', time, AcceptorCorrect_b, 'b', 'LineWidth', 1.2);
    hold on
    plot(time, DonorCorrect_b,'color', [0 0.5 0], 'LineWidth', 1.2);
    %plot(time, DonorCorrect_b + Donor2Correct_b + AcceptorCorrect_b + 300, 'k');
    hold off
    temp=axis;
    temp(3)=BottomLimit_b;
    temp(4)=UpperLimit_b;
    grid on;
    axis(temp);
    %title(['                    Molecule ' num2str(i) '  / ' num2str(NumberofPeaks) '              file: ' filename_head ]); %'   cor.: ' num2str(dbackground) '  ' num2str(abackground) '  ' num2str(d2background) ' ' num2str(leakage12) '  ' num2str(leakage13) ' ' num2str(leakage23) ' ' num2str(gamma12) ' ' num2str(gamma13) '   filter: ' DoesFilterNeed ' Fret:' num2str(FretEc_filter) ' Mean:' num2str(MeanRange) ' Acceptor:' num2str(Acceptor_filter) ' Total:' num2str(Total_filter) ]);
    title(['ALEX Green Laser Molecule' num2str(i) '  / ' num2str(NumberofPeaks) '       file:' filename_head  ' cor.: ' num2str(dbackground_b) '  ' num2str(d2background_b) '  ' num2str(abackground_b) '  ' num2str(dbackground_g) '  ' num2str(d2background_g) '  ' num2str(abackground_g) '  ' num2str(dbackground_r) '  ' num2str(d2background_r) '  ' num2str(abackground_r) '  ' num2str(leakage12) '  ' num2str(leakage21) '  ' num2str(leakage13) '  ' num2str(leakage23) '  ' num2str(gamma12) '  ' num2str(gamma13) ]);
    zoom on;
    
    region_indice = find(Temp_i == i);
    number_region = size(region_indice);
    if number_region ~= 0
        FirstSelectX=[(Tempfirstpoint(region_indice)*timeunit)' (Tempfirstpoint(region_indice)*timeunit)'];
        FirstSelectY=[(zeros(number_region) - 2)' (zeros(number_region) + 2)'];
        LastSelectX=[(Templastpoint(region_indice)*timeunit)' (Templastpoint(region_indice)*timeunit)'];
        LastSelectY=[(zeros(number_region) - 2)' (zeros(number_region) + 2)'];
    end
    
    disp([num2str(i) ' (d=collect dwell times, j=junk)']);
    keyanswer =input('(t=terminate program, b=back, g=go, q=collect photobleaching time) : ','s');
    answer = sscanf(keyanswer, '%s %*s');
    numberofanswer = sscanf(keyanswer, '%*s %f');
    

    % photobleaching analysis
    if answer == 'q'
        [x, y] = ginput(1);
        disp(x);
        t_list(i) = x;
    end
    
    if answer == 'j'
        is_junk(i) = 1;
    end
    
    % dwell time analysis
    if answer == 'd'
        disp('Click for beginning and end of states.');disp('Left/middle/right click for different states.');
        [times,y,button]=ginput;
        
        time1=times(button==1);
        for c=1:2:(sum(button==1)-1)
            t1=ceil(time1(c)/timeunit);
            t2=ceil(time1(c+1)/timeunit);
            DT1(end+1)=abs(time1(c+1)-time1(c));
            DT1id(end+1) = i;
            DT1start(end+1) = time1(c);
            DT1end(end+1) = time1(c+1);
            %             DT1a(end+1)=mean(Acceptors(i,t1:t2));
            %             DT1d(end+1)=mean(Donors(i,t1:t2));
            %             DT1f(end+1)=mean(FRET_Time_Series(t1:t2));
        end
        time2=times(button==2);
        for c=1:2:sum(button==2)-1
            t1=ceil(time2(c)/timeunit);t2=ceil(time2(c+1)/timeunit);
            DT2(end+1)=abs(time2(c+1)-time2(c));
            %             DT2a(end+1)=mean(Acceptors(i,t1:t2));
            %             DT2d(end+1)=mean(Donors(i,t1:t2));
            %             DT2f(end+1)=mean(FRET_Time_Series(t1:t2));
        end
        time3=times(button==3);
        for c=1:2:sum(button==3)-1
            t1=ceil(time3(c)/timeunit);t2=ceil(time3(c+1)/timeunit);
            DT3(end+1)=abs(time3(c+1)-time3(c));
            %             DT3a(end+1)=mean(Acceptors(i,t1:t2));
            %             DT3d(end+1)=mean(Donors(i,t1:t2));
            %             DT3f(end+1)=mean(FRET_Time_Series(t1:t2));
        end
        
    end
    
    if answer=='b'
        if i>1 && history_n > 0
            while history(history_n)==i
                history_n = history_n - 1;
            end
            i=history(history_n)-1;
            history_n = history_n - 1;
        else
            i=i-1;
        end
    else
        history_n = history_n + 1;
        history(history_n)=i;
    end
    
    
    if answer=='g'
        answer=input('number to go : ','s');
        gonumber = str2num(answer);
        if gonumber > 0 && gonumber <= NumberofPeaks
            i = gonumber - 1;
        end
    end
    
    if answer=='t'
        close all;
        cd(OriginalDirectory);
        break;
    end
    
    
end

disp('Program end.')

cd(OriginalDirectory);

% save dwell time data

fprintf('Saving dwell time data if there is any...\n');

newfolder = [filename_head '_analysis'];
mkdir(newfolder);

if ~isempty(DT1)
    %DT1=[DT1;DT1a;DT1d;DT1f]';
    DT1table = [DT1id; DT1start; DT1end; DT1]';
    fname1=[WorkingDirectory '/' newfolder  '/dwelltime1.dat'];
    save(fname1,'DT1table','-ascii','-append');
end
% if ~isempty(DT2)
%     DT2=[DT2;DT2a;DT2d;DT2f]';
%     fname1=[Directory_of_TracesFiles '/' newfolder  '/dwelltime2.dat'];
%     save(fname1,'DT2','-ascii','-append');
% end
% if ~isempty(DT3)
%     DT3=[DT3;DT3a;DT3d;DT3f]';
%     fname1=[Directory_of_TracesFiles '/' newfolder  '/dwelltime3.dat'];
%     save(fname1,'DT3','-ascii','-append');
% end

if sum(is_junk)
    trace_IDs = [1 : NumberofPeaks]';
    is_junk_table = [trace_IDs is_junk];
    fname2 = [WorkingDirectory '/' newfolder  '/is_junk.csv'];
    save(fname2, 'is_junk_table', '-ascii');
end

fprintf('Done.\n');

clear all;
close all;
end
