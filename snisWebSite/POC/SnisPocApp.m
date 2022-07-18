classdef SnisPocApp < Simple.App.App
    methods (Access=protected)
        
        % Overriding load method to register AppControllers
        function load(this)
            this.load@Simple.App.App();
            
            % Register proof of concept controller
            this.registerController(...
                Simple.App.AppControllerBuilder(...
                    class(SnisPocController),...
                    @SnisPocController));
        end
    end
end

