classdef AppSession < Simple.App.App
    % App class decorator.
    % Implement a session persistence on the Application by overriding the
    % PersistenceContainer property, and returning a session-key based instance
    % To access application-context PersistenceContainer access Simple.App.App.PersistenceContainer
    % directly.
    
    properties
        sessionKey = [];
        app = [];
    end
    
    methods (Static,Access=private)
        function rep = sessionContainer(clearFlag)
            persistent sessionRep;
            if nargin >= 1 && clearFlag
                if ~isempty(sessionRep)
                    sessionRep.clearCache();
                end
                sessionRep = [];
            elseif isempty(sessionRep)
                sessionRep = Simple.App.PersistenceContainer();
            end
            rep = sessionRep;
        end
        
        function rep = getSessionContext(key)
            import Simple.App.AppSession;
            sessionRep = AppSession.sessionContainer();
            if sessionRep.hasEntry(key)
                session = sessionRep.get(key);
                rep = session.rep;
                session.timestamp = now;
                sessionRep.set(key, session);
            else
                AppSession.raiseSessionExpiredError(key)
            end
        end
        
        function span = expirationTimespan(new)
            persistent timespan;
            if nargin > 0
                timespan = seconds(new);
            end
            if isempty(timespan)
                timespan = seconds(3600);
            end
            span = new;
        end
    end
    
    methods (Static)
        function configure(expirationTimespan)
            Simple.App.AppSession.expirationTimespan(seconds(expirationTimespan));
        end
        
        function raiseSessionExpiredError(key)
            ex = MException('AppSession:Expired', ['Session expired: ' key]);
            throw(ex);
        end
        
        function clearSessionContainer()
            Simple.App.AppSession.sessionContainer(true);
        end
        
        function key = startNewSession()
            key = guid();
            
            session.rep = Simple.App.PersistenceContainer();
            session.timestamp = now;
            Simple.App.AppSession.sessionContainer.set(key, session);
        end
        
        function isvalid = validateSessionKey(key)
            isvalid = Simple.App.AppSession.sessionContainer.hasEntry(key);
        end
        
        function clearSession(key)
            import Simple.App.*;
            if ~AppSession.validateSessionKey(key)
                return;
            end
            
            session = AppSession.sessionContainer.get(key).rep;
            session.clearCache();
            AppSession.sessionContainer.removeEntry(key);
        end
        
        function clearExpiredSessions()
            import Simple.App.*;
            sessionRep = AppSession.sessionContainer;
            for key = sessionRep.allKeys
                session = sessionRep.get(key);
                if now - session.timestamp > AppSession.expirationTimespan
                    AppSession.clearSession(key);
                end
            end
        end
    end
    
    methods (Access=protected) % Property overrides
        function persister = persistenceContainer_getter(this)
            persister = Simple.App.AppSession.getSessionContext(this.sessionKey);
        end
    end
    
    methods
        function this = AppSession(app, sessionKey)
            import Simple.App.*;
            this.app = app;
            
            if ~AppSession.validateSessionKey(sessionKey)
                AppSession.raiseSessionExpiredError(sessionKey)
            end
            this.sessionKey = sessionKey;
            
            % this is for setting the new timestamp
            persister = this.persistenceContainer();
        end
        
        function controller = getController(this, controllerName)
            controller = this.app.getController(controllerName);
            controller.app = this;
        end
        
        function out = invokeController(controllerName, controllerMethod, params)
            controller = this.getController(controllerName);
            out = controller.invoke(controllerMethod, params);
        end
        
        function callController(controllerName, controllerMethod, params)
            controller = this.getController(controllerName);
            controller.call(controllerMethod, params);
        end
        
    end
end

