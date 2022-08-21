classdef OCSMount
    %OCSMOUNT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %serialPort
        mount
        %logger = SnisOcsApp.getLogger();
        logger = log4m.getLogger();
    end
    
    methods
        function obj = OCSMount(this)
            %this.mount = XerxesMount(obj.serialPort);
        end
    end
    
    methods (Description='api')
        
        function out = slewing(this)
            this.logger.info('OCSMount', 'calling: slewing()')
            out = true; % this.mount.Slewing;
        end
        
        function out = park(this)
            this.logger.info('OCSMount', 'calling: park()');
            out = true; %this.mount.park();
        end

        function out = gotoeq(this, ra, dec)
            this.logger.info('OCSMount' + workerinfo(), ['calling: goto(' ra ', ' dec ', ''eq'')']);
            out = true; %this.mount.goto(ra, dec, 'eq')
        end

        function out = gotoha(this, ha, dec)
            this.logger.info('OCSMount' + workerinfo(), ['calling: goto(' ha ', ' dec ', ''ha'')']);
            out = true; %this.mount.goto(ha, dec, 'ha')
        end
        
        function out = gotohor(this, az, alt)
            this.logger.info("OCSMount" + workerinfo(), ['calling: goto(' az ', ' alt ', ''hor'')']);
            out = true; %this.mount.goto(az, alt, 'hor')
        end

        function out = status(this)
            this.logger.info('OCSMount', 'calling: status()');
            out = 'STATUS'; % this.mount.status();
        end
        
        function tf = tracking(this)
            this.logger.info('OCSMount', 'calling: tracking()');
            tf = true; % this.mount.tracking;
        end
        
        function tf = abortslew(this)
            this.logger.info('OCSMount', 'calling: abortslew()');
            tf = true; % this.mount.abortslew();
        end
        
        function model = MountModel(this)
            model = 'Unknown'; %this.MountModel();
        end
        
        function out = MotorHALimits(this, limit)
            if isempty(limit)
                out = this.MotorHALimit();
            else
                this.MotorHALimit(limit);
            end
        end
        
        function out = MotorDecLimits(this, limit)
            if isempty(limit)
                out = this.MotorDecLimit();
            else
                this.MotorDecLimit(limit);
            end
        end
        
        function out = HAOffset(ticks)
            if isempty(ticks)
                out = this.HAOffset();
            else
                this.HAOffset(ticks);
            end
        end
        
        function out = DecOffset(ticks)
            if isempty(ticks)
                out = this.DecOffset();
            else
                this.DecOffset(ticks);
            end
        end
        
        function out = HATicks(this)
            out = this.HATicks();
        end
        
        function out = DecTicks(this)
            out = this.DecTicks();
        end
        
        function throw(this)
            me = MException('OCS:Mount:throw', 'Intentional exception');
            corr = matlab.lang.correction.AppendArgumentsCorrection('"Stop throwing exceptions :-)"');
            me = me.addCorrection(corr);
            throw(me);
        end
    end
    
    methods
    end
    
end

        
function out = workerinfo()
    w = getCurrentWorker();

    out = "";
    if ~isempty(w)
        if isequal(class(w), 'parallel.cluster.CJSWorker')
            out = " [pid=" + w.ProcessId + "]";
        end
    else
        out = "[no worker]";
    end
end
