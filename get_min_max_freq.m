function peakfreq
%1) cut snippet in even smaller snippets of 10ms
%2) get peak frequency for every snippet (save)
%3) get max and min frequency for each snippet relativ to peak frequency
%(~-25dB)
%4) save 

%1) üblicher loop durch alle wav files
%2) load data
%3) fft rechnen
%4) in windows von ~10ms über fft Ergebnis gehen:
   % -> peak frequency
   % -> min und max freq relativ dazu
   % -> pro wav datei min/max/peak mitteln 
%% 01: GLOBALS
% definde global variables

global listOfFileNames

%% 02: Set Path
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;

% definde global variables
% Step one: Define a starting folder.
start_path = fullfile(matlabroot, '\toolbox');
if ~exist(start_path, 'dir')
	start_path = matlabroot;
end
% Ask user to confirm the folder, or change it.
uiwait(msgbox('Pick a starting folder on the next window that will come up.'));
topLevelFolder = uigetdir(start_path);
if topLevelFolder == 0
	return;
end
fprintf('The top level folder is "%s".\n', topLevelFolder);

% Specify the file pattern.
% Get ALL files using the pattern *.*
% Note the special file pattern.  It has /**/ in it if you want to get files in subfolders of the top level folder.
% filePattern = sprintf('%s/**/*.m; %s/**/*.xml', topLevelFolder, topLevelFolder);
%filePattern = sprintf('%s/**/*.xlsx', topLevelFolder); %for .xlsx data
%filePattern = sprintf('%s/**/*.xls', topLevelFolder); %for .xls data
filePattern = sprintf('%s/**/*.wav',topLevelFolder); %for .wav files
allFileInfo = dir(filePattern);

% Throw out any folders.  We want files only, not folders.
isFolder = [allFileInfo.isdir]; % Logical list of what item is a folder or not.
% Now set those folder entries to null, essentially deleting/removing them from the list.
allFileInfo(isFolder) = [];
% Get a cell array of strings.  
listOfFolderNames = unique({allFileInfo.folder});
numberOfFolders = length(listOfFolderNames);
fprintf('The total number of folders to look in is %d.\n', numberOfFolders);

% Step two: Get a cell array of base filename strings. 
listOfFileNames = {};
listOfFileNames = {allFileInfo.name};
totalNumberOfFiles = length(listOfFileNames);
fprintf('The total number of files in those %d folders is %d.\n', numberOfFolders, totalNumberOfFiles);

prompt = 'Assign a name for saving. Example: C_persp_IC for Isolation Calls of Carollia perspicillata. The name needs to be put in aposthrophes. ';
savename = input(prompt);
fprintf(['The name you chose for saving is ' savename]);
%% 03: define variables

for i = 1: length(listOfFileNames)   
 
    matfilename = listOfFileNames{:,i};
   
    [x,fs] = audioread(matfilename); 
    
    n= 10;          %duration of snippets in ms
    N= (length(x)/fs)*1000; %sample length in ms
    N= N/n; %number of samples to be calculated peak frequnecy for in wav file
    m = fs/1000*10;      %number of samples that make up 10 ms with current samlping rate
    
for k = 1:N
  
    kk=k+((k-1)*m);      %startpoints for the 10 ms snippets 
    
freqrangelow = [10000, 50000]; %neue Grenzen für Fransen: 10kHz bis 50 kHz; Wasser: 20-45 kHz
freqrangehigh = [110000, 190000]; %neue Grenzen für Fransen:110 kHz bis 190 kHz ; Wasser: 60-100 kHz
    
freqmean = meanfreq(x(kk:kk+m,1), fs); 
freqlow = meanfreq(x(kk:kk+m,1),fs, freqrangelow);
freqhigh= meanfreq(x(kk:kk+m,1),fs, freqrangehigh);
   
peakfreq(k,1) = freqmean;
peakfreq(k,2) = freqlow ;
peakfreq(k,3) = freqhigh;

   
end

peakfreq_mean (i,1)= mean(peakfreq(:,1));
peakfreq_mean(i,2) = mean(peakfreq(:,2));
peakfreq_mean(i,3) = mean(peakfreq(:,3));


end

%listOfFileNames = listOfFileNames';
%peakfreq_mean{:,4}=listOfFileNames;                     %original FileName

save(['peakfreq_mean_' savename 'rangelow' freqrangelow 'rangehigh' freqrangehigh '.mat'], ['peakfreq_mean']);    %save 'peakfreq_mean' in .mat file
xlswrite(['peakfreq_mean_' savename 'rangelow' freqrangelow 'rangehigh' freqrangehigh '.xlsx'], peakfreq_mean);   %save 'peakfreq_mean' in .xlsx file
end
