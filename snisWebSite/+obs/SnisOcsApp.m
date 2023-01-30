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
            
            addpath("/home/ocs/matlab/AstroPack/matlab/startup")
            startup_LAST(true,true);
            
            Args.Project = 'LAST';
            [ret, str] = system('hostname -s');
            if ret == 0
                Args.Hostname = str(1:end-1);
                str = strrep(Args.Hostname, 'last', '');
                Args.MountSide = str(end);
                Args.MountId = str2double(str(1:end-1));
            else
                throw(MException('OCS:SnisOcsApp', 'Cannot get hostname'));
            end
            
            if Args.MountSide == "e"
                EquipIds = [ 1, 2 ];
            else
                EquipIds = [ 4, 3 ];
            end
%             
%             if Obj.MountSide == "e"
%                 OtherSide = "w";
%             else
%                 OtherSide = "e";
%             end
%             
%             Node = obs.api.Node();
%             MountLocation = "LAST." + string(Node.NodeId) + "." + Obj.MountNumber;
            
            Obj.Mounts = [ obs.api.makeApi('Location', 'LOCAL.mount') ];
            
            Obj.Cameras = [ ...
                obs.api.makeApi('Location', sprintf("LOCAL.camera%d", EquipIds(1))), ...
                obs.api.makeApi('Location', sprintf("LOCAL.camera%d", EquipIds(2)))  ...
            ];       
%             Obj.PowerSwitches    = [ ...
%                 obs.api.makeApi('Location', sprintf("%s.%s%d", MountLocation, "switch", EquipLocation(1))), ...
%                 obs.api.makeApi('Location', sprintf("%s.%s%d", MountLocation, "switch", EquipLocation(2)))  ...
%             ]; 
            Obj.Focusers    = [ ...
                obs.api.makeApi('Location', sprintf("LOCAL.focuser%d", EquipIds(1))), ...
                obs.api.makeApi('Location', sprintf("LOCAL.focuser%d", EquipIds(2)))  ...
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

