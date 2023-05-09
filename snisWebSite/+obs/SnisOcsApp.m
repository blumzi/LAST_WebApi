classdef SnisOcsApp < Simple.App.App
    
    properties
        Mounts
        Cameras
        PowerSwitches
        Focusers
        Units
        
%         Hostname
%         MountNumber
%         MountSide
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
                MountSide = Hostname(end);
                MountId = str2double(Hostname(1:end-1));
            else
                error("%s: Cannot get hostname", Func);
            end
            
            if MountSide == "e"
                EquipIds = [ 1, 2 ];
            else
                EquipIds = [ 4, 3 ];
            end
            
            Location = sprintf("%s.%d.mount%d", Node.ProjectName, Node.NodeId, MountId);
%              
%             if Obj.MountSide == "e"
%                 OtherSide = "w";
%             else
%                 OtherSide = "e";
%             end
%             
%             Node = obs.api.Node();
%             MountLocation = "LAST." + string(Node.NodeId) + "." + Obj.MountNumber;
            
%            Obj.Mounts = [ obs.api.makeApi('Location', Location) ];
            
%             Obj.Cameras = [ ...
%                 obs.api.makeApi('Location', sprintf("%s.camera%d", Location, EquipIds(1))), ...
%                 obs.api.makeApi('Location', sprintf("%s.camera%d", Location, EquipIds(2)))  ...
%             ];       
             Obj.PowerSwitches    = [ ...
                 obs.api.makeApi('Location', sprintf("%s.%d.pswitch%d%s", Node.ProjectName, Node.NodeId, MountId, "e")), ...
                 obs.api.makeApi('Location', sprintf("%s.%d.pswitch%d%s", Node.ProjectName, Node.NodeId, MountId, "w"))  ...
             ]; 
            Obj.Focusers    = [ ...
                obs.api.makeApi('Location', sprintf("%s.focuser%d", Location, EquipIds(1))), ...
                obs.api.makeApi('Location', sprintf("%s.focuser%d", Location, EquipIds(2)))  ...
            ];  
%             Obj.Units    = [ ...
%                 obs.api.makeApi('Location', sprintf("%s.%s%d", MountLocation, "unit", EquipLocation(1))), ...
%                 obs.api.makeApi('Location', sprintf("%s.%s%d", MountLocation, "unit", EquipLocation(2)))  ...
%                 obs.api.makeApi('Location', sprintf("%s%s.%s%d", MountLocation, OtherSide, "unit", EquipLocation(2)))  ...
%                 obs.api.makeApi('Location', sprintf("%s%s.%s%d", MountLocation, OtherSide, "unit", EquipLocation(2)))  ...
%             ];
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

