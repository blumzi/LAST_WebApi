classdef App < handle
    % App handles application persistence
    % Functionality includes:
    %   singleton instance
    %   application load status
    %   loading of derived application classes for extended functionality
    %   persistence object map PersistenceContainer
    %   class factory, loading of custom factory initializers
    %   controllers
    %   Logger
    %
    properties (Constant)
        ApplicationStatus = struct(...
            'notAvailable', 1,...
            'startup', 2,...
            'loaded', 3,...
            'terminated', 4);
    end
    
    properties (Access=private)
        classFactoryBuilder = [];
        classFactoryInstance = [];
        controllerBuilders = [];
        persistenceContainerInstance = [];
    end
    
    properties (GetAccess=public,SetAccess=private)
        persistenceContainer;
        statusType;
    end
    
    methods % Property accessors
        function persister = get.persistenceContainer(this)
            % PersistenceContainer property getter function - allows overriding in
            % derived classes
            persister = this.persistenceContainer_getter();
        end
        
        function set.persistenceContainer(~, ~)
            error('Don''t set this property, set persistenceContainerInstance instead');
        end
    end
    
    methods (Access=protected) % Overridable property accessors
        function persister = persistenceContainer_getter(this)
            % PersistenceContainer property getter function - allows overriding in
            % derived classes
            persister = this.persistenceContainerInstance;
        end
    end
    
    methods (Access=protected)
        function this = App(classFactoryBuilder)
            import Simple.App.*;
            
            % Ctor
            % Instantiate app PersistenceContainer & class factory
            this.persistenceContainerInstance = PersistenceContainer();
            
            % Instantiate class factory builder
            if nargin >= 1
                this.classFactoryBuilder = classFactoryBuilder;
            else
                this.classFactoryBuilder = ClassFactoryBuilder();
            end
        end
        
        function initiateLifeCycle(this)
            import Simple.App.*;
            
            % Starts application lifecycle events in order
            this.statusType = App.ApplicationStatus.startup;
            
            % load application
            this.load();
            
            this.statusType = App.ApplicationStatus.loaded;
        end
        
        function restart(this)
            this.initiateLifeCycle();
        end
        
        function load(this)
            this.clear();
            Simple.IO.MXML.Factory.init(this.classFactoryBuilder);
        end
        
        function clear(this)
            this.persistenceContainer.clearCache();
            Simple.IO.MXML.Factory.terminate();
            this.controllerBuilders = [];
            
            Simple.App.AppSession.clearSessionContainer();
        end
        
        function registerController(this, controller)
            % Register an AppController
            if isa(controller, 'Simple.App.AppControllerBuilder')
                this.controllerBuilders.(controller.controllerName) = controller;
            else
                throw(MException('App:RegisterController:InvalidControllerRegistration', 'Registered controller must be a valid Simple.App.AppControllerBuilder'));
            end
        end
    end
    
    methods
        function controller = getController(this, controllerName)
            if isfield(this.controllerBuilders, controllerName)
                controller = this.controllerBuilders.(controllerName).build();
                controller.app = this;
            else
                throw(MException('App:GetController:NotRegistered', ['Controller ' controllerName ' not registered']));
            end
            
            if isempty(controller) || ~isa(controller, 'Simple.App.AppController')
                throw(MException('App:GetController:InvalidController', ['Controller ' controllerName ' invalid']));
            end
        end
        
        function out = invokeController(controllerName, controllerMethod, params)
            controller = Simple.App.App.instance.getController(controllerName);
            out = controller.invoke(controllerMethod, params);
        end
        
        function callController(controllerName, controllerMethod, params)
            controller = Simple.App.App.instance.getController(controllerName);
            controller.call(controllerMethod, params);
        end
        
    end
    
    methods (Static, Access=protected)
        function [path, filename] = getLogPath()
            %path  = pwd;
            path = ['/var/log/ocs/api/' datestr(now, 'yyyy-mm-dd')];
            filename = ['app.log'];
        end
    end
    
    methods (Static, Access=private)
        function logError(msg, err, path, fileName)
            if isa(err, 'MException')
                err = getReport(err, 'extended');
            end
            logger = Simple.App.App.logger(path, fileName);
            logger.error('', [msg newline err]);
        end
        
        function app = instance(app, shouldInstantiate, shouldTerminate)
            if nargin < 2
                shouldInstantiate = true;
            end
            if nargin < 3
                shouldTerminate = false;
            end
            
            persistent appInstance;
            
            if shouldTerminate
                if ~isempty(appInstance)
                    appInstance.clear();
                end
                appInstance = [];
            else
                if nargin >= 1 && isa(app, 'Simple.App.App')
                    appInstance = app;
                else
                    if isempty(appInstance) && shouldInstantiate
                        appInstance = Simple.App.App();
                    end
                    app = appInstance;
                end
            end
        end
        
        function bool = hasInstance()
            bool = ~isempty(Simple.App.App.instance([], false));
        end
    end
    
    methods (Static)
        function app = current()
            app = Simple.App.App.instance;
        end
        
        function startInWorkerProcess(app)
            Simple.App.App.start(app.startInWorkerProcess())
        end
        
        function start(app)
            if nargin < 1 || ~isa(app, 'Simple.App.App')
                throw(MException('App:Start:InvalidApp', 'Must load a valid Simple.App.App object'));
            end
            Simple.App.App.instance(app);
            
            app.initiateLifeCycle();
        end
        
        function ref = classFactory()
            app = Simple.App.App.instance;
            ref = app.classFactoryInstance;
            
            if isempty(ref)
                app.classFactoryBuilder.initFactory(ref);
            end
        end
        
        function persister = getPersistenceContainer()
            persister = Simple.App.App.instance().persistenceContainer;
        end
        
        function terminate()
            Simple.App.App.instance([], false, true);
        end
        
        function reset()
            Simple.App.App.instance.restart();
        end
        
        function [type] = status()
            type = Simple.App.App.instance.statusType;
        end
        
        function bool = isReady()
            if ~Simple.App.App.hasInstance()
                bool = false;
                return;
            end
            
            bool = Simple.App.App.instance.statusType == Simple.App.App.ApplicationStatus.loaded;
        end
        
        function key = startNewSession()
            key = Simple.App.AppSession.startNewSession();
        end
        
        function app = loadSession(key)
            app = Simple.App.AppSession(Simple.App.App.instance, key);
        end
        
        function handleException(a, b, path, fileName)
            % handleException(msg, exception, [path, fileName]) - logs the
            % exception and the message. If specified, logs into the
            % specified path and file name
            %
            % handleException(exception)
            if nargin < 4
                fileName = [];
            end
            if nargin < 3
                path = [];
            end
            if ~isa(a, 'MException')
                Simple.App.App.logError(a, b, path, fileName);
            else
                Simple.App.App.logError('', a, path, fileName);
            end
        end
        
        function log = logger(path, fileName)
            [path1, fileName1] = Simple.App.App.instance.getLogPath();
            
            if nargin < 1 || isempty(path)
                path = path1;
            end
            if nargin < 2 || isempty(fileName)
                fileName = fileName1;
            end
            
            fullLogPath = [path '/' fileName];
            
            log = log4m.getLogger(fullLogPath);
            
            if ~strcmp(log.fullpath, fullLogPath)
                log = log4m.forceNewLogger(fullLogPath);
            end
        end
    end
    
end

