classdef Semaphore < handle
    %LOCK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess=public, SetAccess=private)
        Key     uint32
        Status  string
    end
    
    properties(Hidden)
        Logger
    end
    
    properties(Constant,Hidden)        
        Types = [ ...
            obs.api.Equipment.Mount, ...
            obs.api.Equipment.Camera, ...
            obs.api.Equipment.Focuser, ...
            obs.api.Equipment.Switch, ...
            obs.api.Equipment.Unit ...
        ];
    end
    
    methods
        function Obj = Semaphore(Args)
            arguments
                Args.Key        uint32
                Args.EquipType  string
                Args.EquipId    uint32
                Args.Logger
            end
        
            if isfield(Args, 'EquipType') && isfield(Args, 'EquipId')            
            
                for i = 1:numel(Obj.Types)
                    if Args.EquipType == Obj.Types(i)
                        break
                    end
                end
                
                if i > numel(Obj.Types)
                    error("Bad 'EquipType' argument: %s.  Must be a valid obs.api.Equipment type", Args.EquipType);
                end
                
                Obj.Key = 0xBABE0000u32 + bitshift(i, 12, 'uint32') + Args.EquipId;
                
            elseif isfield(Args, 'Key') && ~isempty(Args.Key)
                Obj.Key = Args.Key;
            else
                error("Must supply either a 'Key' (uint32) or both 'EquipType' and 'EquipId' arguments");
            end
            
            Obj.Logger = Args.Logger;
            
            try
                obs.api.semaphore.semaphore('create', Obj.Key, 1);
            catch ex
                if ~isempty(Obj.Logger)
                    Obj.Logger.msgLog(LogLevel.Error, "Could not 'create' semaphore with 'Key'=0x%X for 'EquipType='%s' EquipId=%d, ErrorId=%s, Message=%s", ...
                        Obj.Key, Args.EquipType, Args.EquipId, ex.identifier, ex.message);
                end
            end
                
            Obj.Status = 'created';
        end
        
        function acquire(Obj, Args)
            % Blocks till the semaphore is free
            arguments
                Obj
                Args.Timeout duration
            end
            
            if Obj.Status == "owned"
                return
            end
            
            % TBD: how to kill the blocking 'wait' with a timer
            Obj.Status = "waiting";
            
            try
                obs.api.semaphore.semaphore('wait', Obj.Key);
            catch ex
                if ~isempty(Obj.Logger)
                    Obj.Logger.msgLog(LogLevel.Error, "Could not 'wait' semaphore with 'Key'=0x%X for 'EquipType='%s' EquipId=%d, ErrorId=%s, Message=%s", ...
                        Obj.Key, Args.EquipType, Args.EquipId, ex.identifier, ex.message);
                end
            end
            Obj.Status = 'owned';
        end
        
        function release(Obj)
            % Releases the semaphore
            
            if Obj.Status ~= "owned"
                return;
            end
            
            try
                obs.api.semaphore.semaphore('post', Obj.Key);
            catch ex
                if ~isempty(Obj.Logger)
                    Obj.Logger.msgLog(LogLevel.Error, "Could not 'post' semaphore with 'Key'=0x%X for 'EquipType='%s' EquipId=%d, ErrorId=%s, Message=%s", ...
                        Obj.Key, Args.EquipType, Args.EquipId, ex.identifier, ex.message);
                end
            end
            Obj.Status = "released";
        end
        
        function delete(Obj)
            try
                obs.api.semaphore.semaphore('destroy', Obj.Key);
            catch ex
                if ~isempty(Obj.Logger)
                    Obj.Logger.msgLog(LogLevel.Error, "Could not 'destroy' semaphore with 'Key'=0x%X for 'EquipType='%s' EquipId=%d, ErrorId=%s, Message=%s", ...
                        Obj.Key, Args.EquipType, Args.EquipId, ex.identifier, ex.message);
                end
            end
            Obj.Status = "destroyed";
        end
    end
end
