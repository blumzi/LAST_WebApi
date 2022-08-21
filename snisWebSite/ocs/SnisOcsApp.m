
classdef SnisOcsApp < Simple.App.App
    
    properties
        mounts
        cameras
        pswitches
        focusers
        
        hostname
        mount_number
        mount_side
    end
    
    methods
        function this = SnisOcsApp()
            [ret, str] = system('hostname -s');
            if ret == 0
                this.hostname = str;
                str = strrep(str, 'last', '');
                this.mount_side = str(end);
                this.mount_number = str2double(str(1:end-1));
            else
                throw(MException('OCS:SnisOcsApp', 'Cannot get hostname'));
            end
            
            this.mounts     = containers.Map({'1'},         {OCSMount()});
            this.cameras    = containers.Map({'ne', 'se'},  {OCSCamera(),       OCSCamera()});   % TODO: use numeral keys as well
            this.pswitches  = containers.Map({'ne', 'se'},  {OCSPowerSwitch(),  OCSPowerSwitch()});
            this.focusers   = containers.Map({'ne', 'se'},  {OCSFocuser(),      OCSFocuser()});
        end
    end
    
    methods (Access=protected)
        
        % Overriding load method to register AppControllers
        function load(this)
            this.load@Simple.App.App();
            
            % Register proof of concept controller
            this.registerController(Simple.App.AppControllerBuilder('ocs',@OcsController));
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

