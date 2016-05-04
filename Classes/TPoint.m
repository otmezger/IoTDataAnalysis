classdef TPoint %< Point
    %TPOINT Temperature Meassurement Point
    %   A single measurement point.
    
    properties
        sensorID
        sensorType
        R
        t
        y
        ynorm
        tnorm
        startDate
        endDate
        dtNorm
        unit
        location
        kind
        figureNumber
        DateRange
        cycleSide
        ycomb %combined temperature, set in master class (nevera)
    end 
    
    methods
        function obj = TPoint(object,figurenr)
            % initialization
            if nargin > 0
                obj.R = object;
                obj.sensorID = obj.R.meta.objectId;
                obj.sensorType = obj.R.meta.SensorType;
                obj.kind= obj.R.meta.SensorType.MeterType;
                obj.unit= obj.R.meta.SensorType.Unit;
                
                obj.DateRange = struct;
                obj.DateRange.active = false;
                if (isfield(obj.R.meta.TypeSpecificData,'LocationInMachine'))
                    obj.location = obj.R.meta.TypeSpecificData.LocationInMachine;
                else
                    obj.location = {};
                end
                obj.figureNumber = figurenr;
                
                obj.t = zeros(length(obj.R.data),1);
                obj.y = zeros(length(obj.R.data),1);
                
                for i = 1:1:length(obj.R.data)
                    obj.t(i) = datenum(obj.R.data{i}.timeStamp.iso,'yyyy-mm-ddTHH:MM:SS.FFFZ');
                    obj.y(i) = obj.R.data{i}.value;
%                     if (i>1 && i<length(obj.R.data)
%                         if obj.y(i) == 85
%                             obj.Y(i) = 
%                         end
%                     end
                    
                end
                obj.y = obj.y(obj.y~=85.0);
                obj.t = obj.t(obj.y~=85.0);
                
                % now let's find duplicates
                dt = obj.t(2:end) - obj.t(1:end-1);
                Idt_zero = find(dt==0);
                for i=flipud(Idt_zero) % start from the back
                    if (obj.y(i+1) == obj.y(i))
                        %they are equal, delete one
                        obj.t(i)=[]; %removes this element
                        obj.y(i) = [];
                    end
                end
                if (obj.t(1) > obj.t(end))
                    obj.t = flipud(obj.t);
                    obj.y = flipud(obj.y);
                end
                obj.startDate = datenum(datestr(obj.t(1)+1/(24*60*60),'yyyy-mm-dd HH:MM:SS'));
                    % convert without ms!
                obj.endDate = obj.t(end);
                if strcmp(obj.kind , 'Temperature')
                    if strcmp(obj.location(1:4),'cold')
                        obj.cycleSide = 'cold';
                    elseif strcmp(obj.location(1:4),'warm')
                        obj.cycleSide = 'warm';
                    elseif strcmp(obj.location(1:7),'outside')
                        obj.cycleSide = 'outside';
                    else
                        obj.cycleSide = 'undefined';
                    end
                end
                [obj.tnorm, obj.ynorm ] = obj.normalize();
            end
        end % end of initialization
        
        function h = doPlot(obj)
            h = struct;
            h.fig = figure(obj.figureNumber);
            clf
            hold on
            grid on
            plot(obj.t,obj.y,'*r');
            stairs(obj.tnorm,obj.ynorm,'b');
            if obj.DateRange.active
                set(gca,'XLim',obj.DateRange.fromTo);
            end
            datetick('x','keeplimits');
            title(obj.getDescription('title'));
            legend('raw values','normalized');
            
            
        end % end of doplot
        function descriptionString = getDescription(obj,kind)
            switch kind
                case 'title'
                    descriptionString = strcat([obj.kind ' de '  obj.location  ' en '  obj.unit]);
                case 'xAxis'
                    descriptionString = 'time';
                case 'yAxis'
                    
                    descriptionString = strcat([obj.kind  ' en '  obj.unit]);
                otherwise
                    error('not defined')
            end
            
        end
        function analyze(obj)
            % this function analyses the data. 
            
        end
        function dT = getdT(obj)
            dT = zeros(size(obj.tnorm));
            dT(2:end) = obj.ynorm(2:end) - obj.ynorm(1:end-1);
            % let's filter dT a bit
            windowSize = 1*60;
            b = (1/windowSize)*ones(1,windowSize);
            a = 1;
            
            dT = filter(b,a,dT);
        end
        
        function [tnorm,ynorm] = normalize(obj)
            dt_seg = int32((obj.endDate - obj.startDate) * 60*60*24);
            jota = 1;
            firstDateRaw = obj.startDate;
            nextDateRaw = firstDateRaw; %ini
            
            ynorm = zeros(dt_seg,1); % preallocation
            tnorm = double(0:dt_seg-1)'/(24*60*60) +obj.startDate;
            %tnorm = (obj.startDate:1/(24*60*60):endDate-1)';
            for i = 1:dt_seg
                %thisNormDate = firstDateRaw+double(i)/(60*60*24);
                thisNormDate = tnorm(i);
                while (jota <= length(obj.t)-1) && ((nextDateRaw - thisNormDate)*60*60*24 <= 0)
                    jota = jota +1;
                    nextDateRaw = obj.t(jota);
                end
                dT = obj.y(jota) - obj.y(jota-1);
                dt = (obj.t(jota)- obj.t(jota-1))*60*60*24;
                Tdot = dT/dt; % in K/s

                dt_norm = (thisNormDate- obj.t(jota-1))*60*60*24;

                ynorm(i) = obj.y(jota-1) + dt_norm * Tdot; 
            end
        end % end of normalize
    end % methods
end

