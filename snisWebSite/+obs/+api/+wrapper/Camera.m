classdef Camera
    %OCSMOUNT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        LocalCamera
    end
    
    methods (Description='api')
        function Obj = Camera(Args)
            arguments
                Args.Location string
            end
            
            Obj.LocalCamera = obs.api.Camera('Location', Args.Location);
        end

        function out = status(Obj)
            disp('OCSCamera: status');
            out = Obj.LocalCamera.status();
        end
        
    end
end

