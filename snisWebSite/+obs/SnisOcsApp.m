
classdef SnisOcsApp < Simple.App.App
    
    properties
        Mounts
        Cameras
        Pswitches
        Focusers
        
        Hostname
        Mount_number
        Mount_side
    end
    
    methods
        function Obj = SnisOcsApp()
            [ret, str] = system('hostname -s');
            if ret == 0
                Obj.Hostname = str(1:end-1);
                str = strrep(Obj.Hostname, 'last', '');
                Obj.Mount_side = str(end);
                Obj.Mount_number = str2double(str(1:end-1));
            else
                throw(MException('OCS:SnisOcsApp', 'Cannot get hostname'));
            end
            
            Obj.Mounts     = [ obs.api.handlers.Mount() ];
            Obj.Cameras    = [ obs.api.handlers.Camera(),       obs.api.handlers.Camera() ];
            Obj.Pswitches  = [ obs.api.handlers.PowerSwitch(),  obs.api.handlers.PowerSwitch() ];
            Obj.Focusers   = [ obs.api.handlers.Focuser(),      obs.api.handlers.Focuser() ];
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

