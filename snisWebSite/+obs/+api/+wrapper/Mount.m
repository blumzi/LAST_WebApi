classdef Mount
    %OCSMOUNT Summary of Obj class goes here
    %   Detailed explanation goes here
    
    properties
        LocalMount
        Logger obs.api.ApiLogger
    end
    
    methods
        function Obj = Mount(Args)
            arguments
                Args.Location string
            end
            
            Obj.Logger = obs.api.ApiLogger('Location', Args.Location);
            Obj.LocalMount = obs.api.Mount('Location', Args.Location);
        end
    end
    
    methods (Description='api')
        
        function tf = slewing(Obj)
            Obj.Logger.msgLog(LogLevel.Info, 'Mount' + workerinfo(), ['calling: slewing()']);
            tf = Obj.LocalMount.slewing();
            % out = true; % Obj.LocalMount.Slewing;
        end
        
        function park(Obj)
            Obj.logger.info('Mount', 'calling: park()');
            Obj.LocalMount.park();
        end

        function gotoeq(Obj, ra, dec)
            Obj.logger.info('Mount' + workerinfo(), ['calling: goto(' ra ', ' dec ', ''eq'')']);
            Obj.LocalMount.goto(ra, dec, 'eq')
        end

        function gotoha(Obj, ha, dec)
            Obj.logger.info('Mount' + workerinfo(), ['calling: goto(' ha ', ' dec ', ''ha'')']);
            Obj.LocalMount.goto(ha, dec, 'ha')
        end
        
        function gotohor(Obj, az, alt)
            Obj.logger.info("Mount" + workerinfo(), ['calling: goto(' az ', ' alt ', ''hor'')']);
            Obj.LocalMount.goto(az, alt, 'hor')
        end

        function out = status(Obj)
            Obj.logger.info('Mount', 'calling: status()');
            out = Obj.LocalMount.status();
        end
        
        function tf = tracking(Obj)
            Obj.logger.info('Mount', 'calling: tracking()');
            tf = Obj.LocalMount.tracking;
        end
        
        function abortslew(Obj)
            Obj.logger.info('Mount', 'calling: abortslew()');
            Obj.LocalMount.abortslew();
        end
        
        function model = MountModel(Obj)
            model = Obj.LocalMount.MountModel();
        end
        
%         function out = MotorHALimits(Obj, limit)
%             if isempty(limit)
%                 out = Obj.LocalMount.MotorHALimit();
%             else
%                 Obj.LocalMount.MotorHALimit(limit);
%             end
%         end
%         
%         function out = MotorDecLimits(Obj, limit)
%             if isempty(limit)
%                 out = Obj.MotorDecLimit();
%             else
%                 Obj.MotorDecLimit(limit);
%             end
%         end
%         
%         function out = HAOffset(ticks)
%             if isempty(ticks)
%                 out = Obj.HAOffset();
%             else
%                 Obj.HAOffset(ticks);
%             end
%         end
%         
%         function out = DecOffset(ticks)
%             if isempty(ticks)
%                 out = Obj.DecOffset();
%             else
%                 Obj.DecOffset(ticks);
%             end
%         end
%         
%         function out = HATicks(Obj)
%             out = Obj.HATicks();
%         end
%         
%         function out = DecTicks(Obj)
%             out = Obj.DecTicks();
%         end
        
        function throw(Obj)
            me = MException('OCS:Mount:throw', 'Intentional exception');
            corr = matlab.lang.correction.AppendArgumentsCorrection('"Stop throwing exceptions :-)"');
            me = me.addCorrection(corr);
            throw(me);
        end
    end
    
end
