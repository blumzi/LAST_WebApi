classdef OCSPowerSwitch
    %OCSMOUNT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %serialPort
        mount
    end
    
    methods (Description='api')
        function obj = OCSPowerSwitch()
            %OCSMOUNT Construct an instance of this class
            %   Detailed explanation goes here
            %obj.mount = XerxesMount(obj.serialPort);
        end
        
        function tf = isOn(position)
        end
        
    end
end

