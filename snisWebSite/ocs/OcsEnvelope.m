classdef OcsEnvelope
    %ENVELOP Sort of SOAP envelope
    
    properties
        header;
        body;
        fault;
    end
    
    methods (Access=private)
        function this = OcsEnvelope(), end
        function this = init(this, header, body, fault)
            this.header = header;
            this.body = body;
            this.fault = fault;
        end
    end
    
    methods (Static)
        function env = Response(content)
            env = OcsEnvelope().init(200, content, []);
        end
        function env = Error(status, err, content)
            if isa(err, 'struct')
                fault.identifier = err.identifier;
                fault.message = err.message;
                fault.reason = err.reason;
            elseif isa(err, 'MException')
                fault.identifier = err.identifier;
                fault.message = err.message;
            else
                fault.message = err;
            end
            if isfield(err, 'report')
                fault.report = err.report;
            end
            env = OcsEnvelope().init(status, content, fault);
        end
    end
end


