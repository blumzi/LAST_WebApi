
classdef SnisOcsApp < Simple.App.App
    
    properties
        mounts
        cameras
        pswitches
        focusers
    end
    
    methods
        function this = SnisOcsApp()
            this.mounts     = containers.Map({'1'},         {OCSMount()});
            this.cameras    = containers.Map({'ne', 'se'},  {OCSCamera(),  OCSCamera()});   % TODO: use numeral keys as well
            this.pswitches  = containers.Map({'ne', 'se'},  {OCSSwitch(),  OCSSwitch()});
            this.focusers   = containers.Map({'ne', 'se'},  {OCSFocuser(), OCSFocuser()});
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

