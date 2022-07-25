classdef OCSSwitch < Simple.App.AppController
    %OCSMOUNT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %serialPort
        mount
    end
    
    methods
        function obj = OCSSwitch()
            %OCSMOUNT Construct an instance of this class
            %   Detailed explanation goes here
            %obj.mount = XerxesMount(obj.serialPort);
        end
        
        function tf = isOn(position)
        end
        
    end
end

