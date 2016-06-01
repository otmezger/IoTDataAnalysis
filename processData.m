
%% settings
path(path,'./Classes');
locationID = '1U97q8qaPi';
enableParalellProcesing = true; % not sure if this needs to be. 
%% configure paralell toolbox. 
if enableParalellProcesing
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(4)
    else
        %do nothing. we already have parpool running
    end
end
%% get files
disp('ok. lets try it')
myFiles = dir(strcat('../parseDownloader/exportParse/exportLocation_', locationID,'/export*'));
MachineData = cell(length(myFiles),1);
if enableParalellProcesing 
    parfor iFile =1:length(myFiles)
        data = importJSONFile(iFile,locationID,myFiles);
        MachineData{iFile} =data;
    end %looping over files
else
    for iFile =1:length(myFiles)
        data = importJSONFile(iFile,locationID,myFiles);
        MachineData{iFile} =data;
        % MachineData{iFile}.chiller = ChillerMachine(<ObjetoTPoint_TempCaliente>,<ObjetoTPoint_TempAmbiente>,'name','Chiller 4','cold',<ObjetoTPoint_TempFrio>);
    end %looping over files
end

%% process
Machines = {};
for i=1:1:length(MachineData)
    thisMachine = processMachineData(MachineData{i});
    if isempty(thisMachine)
        %discard this "machine"
    else
        % a real machine, we got real data

        Machines{end+1} = thisMachine; %#ok<SAGROW>
        if isfield(thisMachine,'chiller')
            thisMachine.chiller.exportOnOffEvents();
        end
    end
end
system('say done with matlab.')