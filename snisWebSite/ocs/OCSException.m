classdef OCSException < MException
    methods (Static)
       
    function RaiseFileNotFoundError(request, msg)
        if nargin < 2; msg = ['The requested file ' request.Url ' was not found']; end
        ex = MException('HTTP:E404:NotFound', msg);
        throw(ex);
    end
    methods
        function obj = OCSException(device)
            obj = obj@MException('Could not lock "', device.port, '" within ', device.timeout, ' seconds');
        end
        
        function val = get.ExceptionObject(obj)
            val.message = obj.message;
        end
    end
end

