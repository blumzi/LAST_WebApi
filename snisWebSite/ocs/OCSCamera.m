classdef OCSCamera < OCSDeviceInterface
    %OCSMOUNT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        serialPort
        camera
    end
    
    methods
        function obj = OCSCamera()
            %OCFOCUSER Construct an instance of this class
            %   Detailed explanation goes here
%             obj.serialPort = serialPort;
%             obj.camera = QHYCamera(obj.serialPort);
        end

        function out = status(this)
            disp('OCSCamera: status');
            out = 'status'; % this.camera.status();
        end
        
    end
end

