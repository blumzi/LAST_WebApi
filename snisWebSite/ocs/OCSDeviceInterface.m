classdef OCSDeviceInterface
    %The top of the OCS device interfaces
    %   All specific devices inherit from this class
    
    properties
        logger
    end
    
    methods
        function obj = OCSDeviceInterface()
            %OCSDEVICEINTERFACE Construct an instance of this class
            %   Detailed explanation goes here
            %obj.logger = logger;
        end
        
        function outputArg = devices(obj)
            %Gets a list of the devices that inherited form
            % OCSDeviceInterface
            outputArg = metaclass(obj).InferriorClasses();
        end
    end
end