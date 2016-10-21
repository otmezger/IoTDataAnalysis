%MAIN CODE
%This code needs the json files with sensor data, dowloaded with parseDowloader.
%This code loads all the sensor data in an array named Machines{}

%% settings
path(path,'./Classes');   
locationID = '1U97q8qaPi';
enableParalellProcesing = true; % not sure if this needs to be. 

%% configure paralell toolbox. 
if enableParalellProcesing
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(4)   %4 is the number of physical cores of the computer, may change between computers.
    else
        %do nothing. we already have parpool running
    end
end

%% get files
disp('ok. lets try it')
myFiles = dir(strcat('../parseDownloader/exportParse/exportLocation_', locationID,'/export*'));  % 
MachineData = cell(length(myFiles),1); 
if enableParalellProcesing 
    parfor iFile =1:length(myFiles)
        data = importJSONFile(iFile,locationID,myFiles); %Import json files  
        MachineData{iFile} = data; %Array with machines
    end %looping over files
else
    for iFile =1:length(myFiles)
        data = importJSONFile(iFile,locationID,myFiles);
        MachineData{iFile} = data;
        % MachineData{iFile}.chiller = ChillerMachine(<ObjetoTPoint_TempCaliente>,<ObjetoTPoint_TempAmbiente>,'name','Chiller 4','cold',<ObjetoTPoint_TempFrio>);
    end %looping over files
end

%% Sensors 
%There are some sensors that are shared between machines. 
%Those eight lines assign two sensors to machines that only have one sensor.

MachineData{2}.sensors.sensor_ZDMOFZUCNN = MachineData{4}.sensors.sensor_ZDMOFZUCNN;
MachineData{2}.sensors.sensor_afSzNSM0kQ = MachineData{1}.sensors.sensor_afSzNSM0kQ;
MachineData{3}.sensors.sensor_sAEOCSFNer = MachineData{4}.sensors.sensor_sAEOCSFNer;
MachineData{3}.sensors.sensor_ZDMOFZUCNN = MachineData{4}.sensors.sensor_ZDMOFZUCNN;
MachineData{4}.sensors.sensor_I7bqd64Wu5 = MachineData{3}.sensors.sensor_I7bqd64Wu5;
MachineData{4}.sensors.sensor_AjwYuCDaLr = MachineData{1}.sensors.sensor_AjwYuCDaLr;
MachineData{4}.sensors = rmfield(MachineData{4}.sensors, 'sensor_sAEOCSFNer');
MachineData{4}.sensors = rmfield(MachineData{4}.sensors, 'sensor_ZDMOFZUCNN');

%% process
%Run only this part if you already have loaded the data 

Machines = {}; %Array with processed machines

for i=1:1:length(MachineData)
    thisMachine = processMachineData(MachineData{i});
    if isempty(thisMachine)
        %discard this "machine"
    else
        % a real machine, we got real data

        Machines{end+1} = thisMachine; %#ok<SAGROW>
        if isfield(thisMachine,'chiller')
            %thisMachine.chiller.exportOnOffEvents();
        end
    end
end
disp('Done with matlab.');

%% Some usefull things
%To graph data, run this in matlab command window, after processData finished
% Machines{1}.chiller.doPlot
% Machines{2}.chiller.doPlot
% Machines{3}.chiller.doPlot
% Machines{4}.chiller.doPlot

