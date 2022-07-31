classdef OCSFocuser
    %OCSMOUNT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        serialPort
        focuser
    end
    
    methods (Description='api')
        function obj = OCSFocuser()
            %OCFOCUSER Construct an instance of this class
            %   Detailed explanation goes here
%             obj.serialPort = serialPort;
%             obj.focuser = CelestronFocuser(obj.serialPort);
        end
        
        function tf = moving(this)
            %slewing Wraps focuser.moving

            tf = this.focuser.moving;
        end
        
        function move(this, position)
            this.focuser.move(position);
        end

        function out = status(this)
            out = this.focuser.status();
        end
        
        function tf = tracking(this)
            tf = this.mount.tracking;
        end
        
    end
end

