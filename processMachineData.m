%Function that process the data from the sensors

function Machine = processMachineData(R)  %R is the machine that is procesing
if not(isstruct(R.sensors))
    % this Machine does not contain any senors
    disp(['Machine ',R.machine.objectId,' has no sensors. skipping'])
    Machine = {}; %Return an empty machine
else
    % this machine DOES contain sensors
    thisMachineSensorFieldNames = fieldnames(R.sensors); %Return  the names of the sensors of the machine
    disp(['Machine ',R.machine.objectId,' has ', num2str(length(thisMachineSensorFieldNames)) , ' sensors. Iterating'])
    Machine = R;
    
    for iSensor =1:1:length(thisMachineSensorFieldNames)
        thisSensorFielName = thisMachineSensorFieldNames{iSensor};
        tPoint = TPoint(R.sensors.(thisSensorFielName),1); %Create an object from TPoint class 
        switch tPoint.cycleSide  %Check out the type of temperature sensor
            case 'cold'
                tPoint_cold = tPoint;
            case 'warm'
                tPoint_warm = tPoint;
            case 'outside'
                tPoint_outside = tPoint;
            otherwise
                disp('error!!! tPoint.cycleSide not set')
        end
    end
    % we asume we have warm and outside!
    if not(isfield(R,'machineONOFF'))
        % no info, we st it manually
        R.machineONOFF = struct;
        R.machineONOFF.on = false;
    end
    %If there are sensors of warm and outside type, an objet of the Chillermachine is created.
    %The ChillerMachine object allow to graph the sensors data.
    if exist('tPoint_warm','var') && exist('tPoint_outside','var')
        if exist('tPoint_cold','var')
            thiChiller = ChillerMachine(tPoint_warm,tPoint_outside,'machine',Machine.machine,'lastONOFFStatus',R.machineONOFF,'cold',tPoint_cold);
        else
            thiChiller = ChillerMachine(tPoint_warm,tPoint_outside,'machine',Machine.machine,'lastONOFFStatus',R.machineONOFF);
        end
        Machine.chiller = thiChiller; %The ChillerMachine object is added in the Machine array with the name chiller
    end
end
end