classdef Semaphore < handle
    %LOCK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess=public, SetAccess=private)
        Key uint32
        Status string
    end
    
    methods
        function Obj = Semaphore(Args)
            arguments
                Args.Key uint32
                Args.EquipType string
                Args.EquipId uint32
            end
        
            if isfield(Args, 'EquipType') && isfield(Args, 'EquipId')            
            
                switch Args.EquipType
                    case obs.api.Equipment.Mount
                        Obj.Key = 0xbabe1000 + Args.EquipId;
                    case obs.api.Equipment.Camera
                        Obj.Key = 0xbabe2000 + Args.EquipId;
                    case obs.api.Equipment.Focuser
                        Obj.Key = 0xbabe3000 + Args.EquipId;
                    case obs.api.Equipment.Switch
                        Obj.Key = 0xbabe4000 + Args.EquipId;
                    case obs.api.Equipment.Unit
                        Obj.Key = 0xbabe5000 + Args.EquipId;
                    otherwise
                        error("'EquipType' must be a valid obs.api.Equipment type");
                end
                
            elseif isfield(Args, 'Key') && ~isempty(Args.Key)
                Obj.Key = Args.Key;
            else
                error("Must supply either a 'Key' (uint32) or both 'EquipType' and 'EquipId' arguments");
            end
            
            obs.api.semaphore.semaphore('create', Obj.Key, 1);
            Obj.Status = 'created';
        end
        
        function acquire(Obj)
            % Blocks till the semaphore is free
            
            if Obj.Status == "owned"
                return
            end
            
            Obj.Status = "waiting";
            obs.api.semaphore.semaphore('wait', Obj.Key);
            Obj.Status = 'owned';
        end
        
        function release(Obj)
            % Releases the semaphore
            
            if Obj.Status ~= "owned"
                return;
            end
            
            obs.api.semaphore.semaphore('post', Obj.Key);
            Obj.Status = "released";
        end
        
        function delete(Obj)
            obs.api.semaphore.semaphore('destroy', Obj.Key);
            Obj.Status = "destroyed";
        end
    end
end
