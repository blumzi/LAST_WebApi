classdef PersistenceContainer < handle
    %PersistenceContainer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=private)
        context;
    end
    
    methods
        function this = PersistenceContainer()
            this.context = containers.Map();
        end
    
        function clearCache(this)
            this.context.remove(this.context.keys);
        end
        
        function value = get(this, key)
        % Gets an entry from the context object holder
            if this.hasEntry(key)
                value = this.context(key);
            else
                value = [];
            end
        end
        
        function set(this, key, value)
        % Sets specified value in an entry in the context object holder
            this.context(key) = value;
        end
        
        function removeEntry(this, key)
            if this.hasEntry(key)
                this.context.remove(key);
            end
        end
        
        function containsKey = hasEntry(this, key)
        % Determines whether a specific key exists in the context object
        % holder
            containsKey = this.context.isKey(key);
        end
        
        function keys = allKeys(this)
            keys = this.context.keys;
        end
    end
    
end

