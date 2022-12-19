classdef Focuser
    %OCSMOUNT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        LocalFocuser
        Position
    end
    
    methods (Description='api')
        function Obj = Focuser(Args)
            arguments
                Args.Location
            end
            
            Obj.LocalFocuser = obs.api.Focuser('Location', Args.Location);
        end

        function out = status(Obj)
            out = Obj.LocalFocuser.status();
        end      
    end
    
    methods
        
        function pos = get.Position(Obj)
            pos = Obj.LocalFocuser.Position();
        end
        
        function set.Position(Obj, pos)
            Obj.LocalFocuser.Position = pos;
        end
    end
end

