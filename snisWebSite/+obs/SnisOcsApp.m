classdef SnisOcsApp < Simple.App.App
    
    properties
        Mounts
        Cameras
        PowerSwitches
        Focusers
        Units
        
        Hostname
        MountNumber
        MountSide
    end
    
    methods
        function Obj = SnisOcsApp()
            [ret, str] = system('hostname -s');
            if ret == 0
                Obj.Hostname = str(1:end-1);
                str = strrep(Obj.Hostname, 'last', '');
                Obj.MountSide = str(end);
                Obj.MountNumber = str2double(str(1:end-1));
            else
                throw(MException('OCS:SnisOcsApp', 'Cannot get hostname'));
            end
            
            if Obj.MountSide == "e"
                EquipLocation = [ 1, 2 ];
            else
                EquipLocation = [ 3, 4 ];
            end
            
            Node = obs.api.Node();
            MountLocation = "LAST." + string(Node.NodeId) + "." + Obj.MountNumber;
            Obj.Mounts     = [ obs.api.wrapper.Mount('Location', MountLocation) ];
%             Obj.Cameras    = [ ...
%                 obs.api.wrapper.Camera('Location', sprintf("%s.%s%d", MountLocation, "cam", EquipLocation(1))), ...
%                 obs.api.wrapper.Camera('Location', sprintf("%s.%s%d", MountLocation, "cam", EquipLocation(2)))  ...
%             ];       
%             Obj.PowerSwitches    = [ ...
%                 obs.api.wrapper.PowerSwitch('Location', sprintf("%s.%s%d", MountLocation, "switch", EquipLocation(1))), ...
%                 obs.api.wrapper.PowerSwitch('Location', sprintf("%s.%s%d", MountLocation, "switch", EquipLocation(2)))  ...
%             ]; 
            Obj.Focusers    = [ ...
                obs.api.wrapper.Focuser('Location', sprintf("%s.%s%d", MountLocation, "foc", EquipLocation(1))), ...
                obs.api.wrapper.Focuser('Location', sprintf("%s.%s%d", MountLocation, "foc", EquipLocation(2)))  ...
            ];  
%             Obj.Units    = [ ...
%                 obs.api.wrapper.Unit('Location', sprintf("%s.%s%d", MountLocation, "unit", EquipLocation(1))), ...
%                 obs.api.wrapper.Unit('Location', sprintf("%s.%s%d", MountLocation, "unit", EquipLocation(2)))  ...
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

