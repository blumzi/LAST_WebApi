classdef SnisOcsApp < Simple.App.App
    
    properties
        Mounts
        Cameras
        PowerSwitches
        Focusers
        Units
        
        Futures = cell(0);
    end
    
    methods
        function Obj = SnisOcsApp()
            
            Stack = dbstack();
            Func = Stack(1).name;
            
            addpath("/home/ocs/matlab/AstroPack/matlab/startup")
            startup_LAST(true,true);
            
            Node = obs.api.Node();
            if ~strcmp(Node.ProjectName, 'LAST')
                error("%s: Don't know (yet?) how to handle ProjectName '%s'", Func, Node.ProjectName);
            end
            
            [Ret, Hostname] = system('hostname -s');
            if Ret == 0
                Hostname = Hostname(1:end-1); % trim newline
                if ~startsWith(Hostname, 'last')
                    error("%s: Hostname (%s) does not start with 'last'", Func, Hostname);
                end
                Hostname = strrep(Hostname, 'last', '');
                UnitSide = Hostname(end);
                UnitId = str2double(Hostname(1:end-1));
            else
                error("%s: Cannot get hostname", Func);
            end
            
            if UnitSide == "e"
                OtherSide = "w";
                EquipIds = [ 1, 2 ];
            else
                OtherSide = "e";
                EquipIds = [ 4, 3 ];
            end
            
            Location = sprintf("%s.%d", Node.ProjectName, Node.NodeId);
            UnitLocation = sprintf("%s.unit%d%s", Location, UnitId, UnitSide);

% TODO: Enrico probably doesn't want a hardwritten scheme here, but
%   something which can be loaded from configuration files. To allow
%   e.g. prototype test rigs with all equipment connected to a single
%   computer, or mounts with a number of telescopes different than four
            
            
            Obj.Mounts = [ obs.api.makeApi('Location', sprintf('%s.mount',UnitLocation)) ];
            
             Obj.Cameras = [ ...
                 obs.api.makeApi('Location', sprintf("%s.camera%d", UnitLocation, EquipIds(1))), ...
                 obs.api.makeApi('Location', sprintf("%s.camera%d", UnitLocation, EquipIds(2)))  ...
             ];

             Obj.PowerSwitches    = [ ...
                 obs.api.makeApi('Location', sprintf("%s.pswitch%d%s", Location, UnitId, "e")), ...
                 obs.api.makeApi('Location', sprintf("%s.pswitch%d%s", Location, UnitId, "w"))  ...
             ]; 
            Obj.Focusers    = [ ...
                obs.api.makeApi('Location', sprintf("%s.focuser%d", UnitLocation, EquipIds(1))), ...
                obs.api.makeApi('Location', sprintf("%s.focuser%d", UnitLocation, EquipIds(2)))  ...
            ];
            Obj.Units    = [ ...
                obs.api.makeApi('Location', sprintf("%s.%02d%s", Location, UnitId, "e")), ...
                obs.api.makeApi('Location', sprintf("%s.%02d%s", Location, UnitId, "w"))  ...
%                 obs.api.makeApi('Location', sprintf("%s.%s%d", UnitLocation, "unit", EquipLocation(1))), ...
%                 obs.api.makeApi('Location', sprintf("%s.%s%d", UnitLocation, "unit", EquipLocation(2)))  ...
%                 obs.api.makeApi('Location', sprintf("%s%s.%s%d", UnitLocation, OtherSide, "unit", EquipLocation(2)))  ...
%                 obs.api.makeApi('Location', sprintf("%s%s.%s%d", UnitLocation, OtherSide, "unit", EquipLocation(2)))  ...
            ];
        end
        
        function handleFutures(Obj, httpServer)  
            if isempty(Obj.Futures)
                return;
            end
            
            for i = 1:numel(Obj.Futures)
                f = Obj.Futures{i};
                
                if ~isempty(f.Error)
                    httpServer.server.logError(f.Error);
                    Obj.Futures(i) = [];
                elseif f.State == "finished" && ~f.Read
                    try
                        [request, ex, token] = fetchOutputs(f);
                    catch ex
                        httpServer.server.logError(ex);
                        Obj.Futures(i) = [];
                        continue;
                    end
                    httpServer.server.handleBackgroundRequest(request, ex, token);
                    Obj.Futures(i) = [];
                elseif f.State == "failed"
                    httpServer.server.log("discarding a failed future", '', httpServer.server.LogLevel.Debug);
                    Obj.Futures(i) = [];
                end
            end
        end
    end
    
    methods (Access=protected)
        
        % Overriding load method to register AppControllers
        function load(Obj)
            Obj.load@Simple.App.App();
            
            % Register proof of concept controller
            Obj.registerController(Simple.App.AppControllerBuilder('ocs',@OcsController));
        end
    end
    
    methods (Static)
       
        function RaiseInvalidDeviceError(request, msg)
            if nargin < 2; msg = 'Invalid device'; end
            ex = MException('OCS:Device:Invalid', msg);
            throw(ex);
        end
        
        function RaiseInvalidUnitError(request, msg)
            if nargin < 2; msg = 'Invalid unit'; end
            ex = MException('OCS:Unit:Invalid', msg);
            throw(ex);
        end
        
        function RaiseInvalidMethodError(request, msg)
            if nargin < 2; msg = 'Invalid method'; end
            ex = MException('OCS:Method:Invalid', msg);
            throw(ex);
        end
    end
    
end

