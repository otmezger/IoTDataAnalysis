function Machine = processMachineData(R)
if not(isstruct(R.sensors))
    % this Machine does not contain any senors
    disp(['Machine ',R.machine.objectId,' has no sensors. skipping'])
    Machine = {};
else
    % this machine DOES contain sensors
    thisMachineSensorFieldNames = fieldnames(R.sensors);
    disp(['Machine ',R.machine.objectId,' has ', num2str(length(thisMachineSensorFieldNames)) , ' sensors. Iterating'])
    Machine = R;
    
    for iSensor =1:1:length(thisMachineSensorFieldNames)
        thisSensorFielName = thisMachineSensorFieldNames{iSensor};
        tPoint = TPoint(R.sensors.(thisSensorFielName),1);
        switch tPoint.cycleSide
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
    if exist('tPoint_warm','var') && exist('tPoint_outside','var')
        if exist('tPoint_cold','var')
            thiChiller = ChillerMachine(tPoint_warm,tPoint_outside,'machine',Machine.machine,'lastONOFFStatus',R.machineONOFF,'cold',tPoint_cold);
        else
            thiChiller = ChillerMachine(tPoint_warm,tPoint_outside,'machine',Machine.machine,'lastONOFFStatus',R.machineONOFF);
        end
        Machine.chiller = thiChiller;
    end
end
end