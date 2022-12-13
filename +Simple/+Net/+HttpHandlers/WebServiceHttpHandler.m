classdef WebServiceHttpHandler < Simple.Net.HttpHandlers.HttpHandler
    %WEBSERVICEHTTPHANDLER Summary of this class goes here
    %   Detailed explanation goes here
        
    methods
        function ismatch = matches(this, request, app)
            ismatchOriginal = any(regexp(request.Filename, '^\/?\w+(?:\/\w+)?\/?$'));
            ismatchOcs = any(regexp(request.Filename, ...
                '\/?(api)\/(v\d+)\/((' + strjoin(obs.api.Equipment.Aliases, '|') + '))\/(\d+|[NnSs][WwEe])\/(\w+)'));
            ismatch = ismatchOriginal | ismatchOcs;
        end
        
        function handleRequest(this, request, app)
            serviceUrl=request.Filename;
            response = request.Response;
            
            if ~isempty(serviceUrl) > 0 && serviceUrl(1) == '/'
                serviceUrl = serviceUrl(2:end);
            end
            if ~isempty(serviceUrl) > 0 && serviceUrl(end) == '/'
                serviceUrl = serviceUrl(1:end-1);
            end
            serviceUrlParts = strsplit(serviceUrl, '/');
            
            isOcs = strcmp(serviceUrlParts{1}, 'ocs');
            
            nparts = length(serviceUrlParts);
            if nparts == 1 
                % Handle Service Methods Listing
                foo = @Simple.Net.HttpHandlers.WebServiceHttpHandler.generateControllerMethodsHTML;
                response.write(foo(request, this.getController(request, app, serviceUrlParts{1}), serviceUrlParts{1}));
            elseif nparts == 2 || (isOcs && nparts == 6)
                % Invoke service method
                if isOcs
                    response.ContentType='application/json; charset=UTF-8';
                    apiVersion = serviceUrlParts{3};
                    device = serviceUrlParts{4};
                    unitId = serviceUrlParts{5};
                    method = serviceUrlParts{6};
                    output = this.invokeOcsServiceMethod(request, response, app, device, unitId, method);
                    response.write(jsonencode(struct('Value', output...
                        , 'ErrorId', string(nan)...
                        , 'ErrorMessage', string(nan)...
                        , 'ErrorReport', string(nan))));
                else
                    response.ContentType='application/xml; charset=UTF-8';
                    output = this.invokeServiceMethod(request, response, app, serviceUrlParts{1}, serviceUrlParts{2});
                    responseEnvelope = Simple.Net.Envelope.Response(output);
                    response.write(Simple.IO.MXML.toxml(responseEnvelope));
                end
                
            else
                Simple.Net.HttpServer.RaiseBadHttpHandlerMapping(request, class(this))
            end
        end
    end
    
    methods (Access=private)
        function controller = getController(this, request, app, controllerName)
            try
                controller = app.getController(controllerName);
            catch 
                Simple.Net.HttpServer.RaiseFileNotFoundError(request, ['WebService ' controllerName ' not available']);
            end
        end
        
        function output = invokeServiceMethod(this, request, response, app, serviceName, serviceMethodName)
            % Inspect controller
            controller = this.getController(request, app, serviceName);
            methodMC = this.getServiceMethodDescriptor(controller, serviceMethodName);

            % If method is not available
            if isempty(methodMC)
                Simple.Net.HttpServer.RaiseFileNotFoundError(request, ['WebService method ' serviceName '.' serviceMethodName ' not found']);
            end
            
            % Prepare in/out arguments
            nOutArgs = length(methodMC.OutputNames);
            outArgs = cell(1, nOutArgs);
            inArgs = this.mapMethodArguments(request, methodMC);

            % Invoke controllers method
            [outArgs{:}] = controller.(serviceMethodName)(inArgs{:});
            
            % return output arguments as a struct (which can be serialized
            % easily)
            for oai = 1:nOutArgs
                output.(methodMC.OutputNames{oai}) = outArgs{oai};
            end
        end
        
        function methodMC = getServiceMethodDescriptor(this, controller, serviceMethodName)
            % Gets the method descriptor metaclass for the required service
            % method
            ctrlMC = metaclass(controller);
            methodMC = [];
            for i = 1:length(ctrlMC.Methods)
                currMethodMC = ctrlMC.Methods{i};
                if strcmp(currMethodMC.Name, serviceMethodName)
                    methodMC = currMethodMC;
                    break;
                end
            end
        end
        
        function args = mapMethodArguments(this, request, methodMC)
            %mapMethodArguments Maps all arguments specified in the request either in the
            % query string or as post content to the appropriate method
            % parameters by their names.
            % Returns a cell array with the values of all in arguments
            % expected by the service method. missing parameters are
            % assined empty vectors []
            
            nargs = length(methodMC.InputNames);
            args = cell(1, nargs-1);
            for i = 2:nargs
                % For each method parameter, search it first in post
                % content and second in query string to get the value,
                % otherwise put and empty vector.
                argName = methodMC.InputNames{i};
                args{i-1} = request.get(argName);
            end
        end
        
        function controller = getOcsController(this, request, app, controllerName)
            try
                controller = app.getController(controllerName);
            catch
                Simple.Net.HttpServer.RaiseFileNotFoundError(request, [ 'WebService' controllerName ' not available']);
            end
            
        end
        
        
        function output = invokeOcsServiceMethod(this, request, response, app, requestedDevice, requestedUnit, requestedMethod)
             
            [ret, str] = system('hostname -s');
            if ret == 0
                str = strrep(str, 'last', '');
                mount_side = str(end-1);
                mount_number = str2double(str(1:end-2));
            else
                throw(MException('OCS:SnisOcsApp:invokeOcsServiceMethod', 'Cannot get hostname'));
            end
            
            if obs.api.Equipment.isMount(requestedDevice)
                units = app.current.Mounts;
            elseif obs.api.Equipment.isCamera(requestedDevice)
                units = app.current.Cameras;
            elseif obs.api.Equipment.isFocuser(requestedDevice)
                units = app.current.Focusers;
            elseif obs.api.Equipment.isSwitch(requestedDevice)
                units = app.current.Switches;
            else
                SnisOcsApp.RaiseInvalidDeviceError(request, ...
                    "Invalid device '" + requestedDevice + "'. Valid devices are: " + strjoin(obs.api.Equipment.Aliases, ', ') );
            end
            
            % Unit IDs:
            %  when requestedDevice is 'mount':  only '1'
            %  otherwise they must be two-letter strings (e.g. 'ne', 'sw',
            %  etc.), where the second letter must be the same as
            %  app.mount_side (either 'e' or 'w')
            
            if mount_side == 'e'
                valid_units = [1, 2];
            elseif mount_side == 'w'
                valid_units = [3, 4];
            end
            
            requestedUnit = str2num(requestedUnit);
            if obs.api.Equipment.isMount(requestedDevice)
                if requestedUnit ~= 1
                    SnisOcsApp.RaiseInvalidUnitError(request, ...
                        "Invalid unitID " + requestedUnit + " for device '" + requestedDevice  + "'. Valid unit ID is: 1");
                end            
            elseif mount_side == 'e' && ~ismember(requestedUnit, valid_units)
                err = "Invalid unitID " + requestedUnit + " for device " + requestedDevice + ...
                    ". Valid unit IDs are: [1, 2]";
                SnisOcsApp.RaiseInvalidUnitError(request, err);            
            elseif mount_side == 'w' && ~ismember(requestedUnit, valid_units)
                err = "Invalid unitID " + requestedUnit + " for device " + requestedDevice + ...
                    ". Valid unit IDs are: [3, 4]";
                SnisOcsApp.RaiseInvalidUnitError(request, err);
            end
            
                        
            % 'units' is the dictionary of current units for the requested
            % device type (e.g. mount, camera, focuser, etc.)
            
            if mount_side == 'e' && ismember(requestedUnit, valid_units)
                unit = units(requestedUnit);
            elseif mount_side == 'w' && ismember(requestedUnit, valid_units)
                unit = units(requestedUnit - 2);
            else
                SnisOcsApp.RaiseInvalidUnitError(request, ...
                    "Invalid unitID '" + requestedUnit + "' for device " + requestedDevice + ...
                    ". Current valid units IDs are: [" + strjoin(string(valid_units), ', ') + "]");
            end
            
            validMethods = {};
            methods = {};
            m = metaclass(unit);
            for i = 1:length(m.MethodList())
                if strcmp(m.MethodList(i).Description, 'api')
                    validMethods{end+1} = m.MethodList(i).Name;
                    s = "";
                    mc = m.MethodList(i);
                    if ~isempty(mc.OutputNames)
                        s = join(mc.OutputNames, ',') + " = ";
                    end
                    s = s + mc.Name + "(";
                    if numel(mc.InputNames) > 1                     
                        for j = 2:numel(mc.InputNames)
                            s = s + mc.InputNames(j) + ',';
                        end
                    end
                    s = strip(s, ',') + ")";
                    methods{end+1} = s;
                end
            end
            
            if strcmp(requestedMethod, "methods")
                output = {methods};
                return
            end
            
            method = [];
            for i = 1:length(m.MethodList())
                if strcmp(requestedMethod, m.MethodList(i).Name)
                    method = m.MethodList(i);
                    break;
                end
            end
            
            if isempty(method)
                SnisOcsApp.RaiseInvalidMethodError(request, ...
                    "Invalid method '" + requestedMethod + "' for device '" + requestedDevice + "'. Valid methods are: [" + strjoin(validMethods, ', ') + "]");
            end
            
            % Prepare in/out arguments
            nOutArgs = length(method.OutputNames);
            outArgs = cell(1, nOutArgs);
            inArgs = this.mapMethodArguments(request, method);

            % Invoke controller's method  
            [outArgs{:}] = unit.(method.Name)(inArgs{:});
                
            
            % return output arguments as a struct (which can be serialized
            % easily)
            for oai = 1:nOutArgs
                output.(method.OutputNames{oai}) = outArgs{oai};
            end
        end
    end
    
    methods(Static,Access=private)
        function html = generateControllerMethodsHTML(request, controller, controllerName)

            currentPath = which('Simple.Net.HttpServer');
            currentPath = currentPath(1:find(currentPath=='/',1,'last'));

            % Load html template
            fid = fopen([currentPath 'Templates/ServiceMethodListing.html']);
            html = fread(fid, '*char')';
            fclose(fid);

            % Load html template
            fid = fopen([currentPath 'Templates/ServiceMethodDetails.html']);
            methodHtml = fread(fid, '*char')';
            fclose(fid);

            % Load html template
            fid = fopen([currentPath 'Templates/ServiceMethodParam.html']);
            parameterHtml = fread(fid, '*char')';
            fclose(fid);

            % inspect controller

            controllerMetaClass = metaclass(controller);
            serviceMethods = controllerMetaClass.MethodList;

            % build methods html view
            methodsHtml = '';
            for smi = 1:length(serviceMethods)
                method = serviceMethods(smi);
                if strcmp(method.Name,controllerMetaClass.Name) ||...
                   ~strcmp(method.DefiningClass.Name, controllerMetaClass.Name) ||...
                   ~strcmp(method.Access, 'public') || method.Static || method.Abstract || method.Hidden
                    continue;
                end
                currMethodHTML = strrep(methodHtml, '{ServiceMethodURL}', ...
                    [lower(regexprep(request.Protocol, '\/.*', '')) '://' request.Host '/' controllerName '/' method.Name]);
                currMethodHTML = strrep(currMethodHTML, '{MethodName}', method.Name);

                currMethodParams = '';
                for pii = 2:length(method.InputNames)
                    currMethodParams = [currMethodParams strrep(parameterHtml, '{ParamName}', method.InputNames{pii})];
                end
                currMethodHTML = strrep(currMethodHTML, '{ServiceMethodParameters}', currMethodParams);
                methodsHtml = [methodsHtml, sprintf('\n\r'), currMethodHTML];
            end

            html = strrep(strrep(html, '{ServiceName}', controllerName), '{Methods}', methodsHtml);
        end
    end
end

