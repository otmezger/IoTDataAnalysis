classdef ChillerMachine
    %NEVERA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %must have properties:
        warm
        outside
        % optional
        cold
        machine
        %amperaje
        %potencia
        %voltaje
        startDate
        endDate
    end
    
    methods
        %% -- constructor
        function obj = ChillerMachine(warm,outside,varargin)
            p = inputParser; % from http://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
            addRequired(p,'warm',@isobject);
            addRequired(p,'outside',@isobject);
            
            addOptional(p,'cold',@isobject);
            addOptional(p,'machine',@isobject);
            %addOptional(p,'voltaje',@isobject);
            %addOptional(p,'amperaje',@isobject);
            %addOptional(p,'potencia',@isobject);
            
            p.KeepUnmatched = true;
            
            parse(p,warm,outside,varargin{:})
            if ~isempty(p.Results)
                if isfield(p.Results,'cold')
                    obj.cold= p.Results.cold;
                end
                if isfield(p.Results,'machine')
                    obj.machine = p.Results.machine;
                else
                    obj.machine = 'unnammed';
                end
                
            end
            % initialization
            obj.warm= warm;
            obj.outside = outside;
            
            startDate_ = [
                min(obj.warm.tnorm),...
                min(obj.outside.tnorm),...
                ];
            endDate_ = [
                max(obj.warm.tnorm),...
                max(obj.outside.tnorm),...
                ];
            
            obj.startDate = max(startDate_);
            obj.endDate = min(endDate_);
            
            
            clear  startDate_ endDate_
            % what is the index of t1 and t2?
            
        end % end of initialization
        %% -- doPlot
        function h=doPlot(obj)
            tmin = obj.warm.startDate;
            tmax = obj.warm.endDate;
            h = struct;
            h.fig = figure(1);
            clf
            hold on
            grid on
            title(obj.machine.Name);
            legendString = {};
            iLegend = 0;
            %stairs(aprocam4frio.tnorm,aprocam4frio.ynorm,'b-')
            stairs(obj.warm.tnorm,obj.warm.ynorm,'r-'); 
            iLegend = iLegend + 1; legendString{iLegend} = 'T_{Compressor}'; 
            
            stairs(obj.outside.tnorm,obj.outside.ynorm,'m-');
            iLegend = iLegend + 1; legendString{iLegend} = 'T_{Outside}'; 
            if (isobject(obj.cold))
                stairs(obj.cold.tnorm,obj.cold.ynorm,'b-');
                iLegend = iLegend + 1; legendString{iLegend} = 'T_{Cold}';
            end
            
            plot([tmin,tmax],-15*[1,1],':');
            iLegend = iLegend + 1; legendString{iLegend} = 'T_{Configuraci?n}';
            
            
            %plot(obj.warm.tnorm,500*obj.warm.getdT(),'k-')
            plot([obj.warm.tnorm(1),obj.warm.tnorm(end)],[10,10],'b-');
            plot([obj.warm.tnorm(1),obj.warm.tnorm(end)],-0.05*500*[1,1],'b-');
            set(gca,'XLim',[tmin,tmax]);
            datetick('x','keeplimits');
            legend(legendString);
            xlabel('date');
            ylabel(sprintf('Temperature in %cC',char(176)));
            
            
            
            
        end % end of doPlot
       
        %% -- powerAnalysis
        function h = powerAnalysis(obj,figNr)
            h = struct;
            h.fig = figure(figNr);
            clf
            hold on
            grid on
            stairs(obj.potencia.t,obj.potencia.y,'r-','LineWidth',2);
            stairs(obj.voltaje.t,obj.voltaje.y,'b-','LineWidth',2);
            stairs(obj.amperaje.t,obj.amperaje.y,'m-','LineWidth',2);
            % stairs(obj.amperaje.t,obj.amperaje.y,'m-','LineWidth',2);
            % 2DO: interpolate in pwer and current!
            
        end %% end of powerAnalysis
        
    end % end of methods
    
end

