classdef Camera
    %OCSMOUNT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        serialPort
        camera
    end
    
    methods (Description='api')
        function obj = Camera()
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

