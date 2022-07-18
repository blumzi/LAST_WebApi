classdef SnisPocController < Simple.App.AppController
    methods
        function error(this)
            error('an error occured');
        end
        
        function out = add(this, n1, n2)
            out = str2double(n1) + str2double(n2);
        end
        
        function out = append(this, str1, str2)
            out = [str1 str2];
        end
        
        function [out1, out2] = split(this, str)
            n = length(str);
            if n >= 2
                out1 = str(1:floor(n/2));
                out2 = str(floor(n/2)+1:end);
            else
                out1 = str;
                out2 = 'empty';
            end
        end
        
        function out = persistentHitCounter(this)
            x = this.app.persistenceContainer.get('x');
            if isempty(x); x = 0; end
            x = x+1;
            this.app.persistenceContainer.set('x', x);
            out = x;
        end
    end
end

