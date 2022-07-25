if exist('server', 'var') && server.isActive
    server.stop();
    delete(server);
end

path = which('SnisPOC');
path = path(1:find(path == '/', 1, 'last') - 1);
path = path(1:find(path == '/', 1, 'last'));

config = Simple.Net.HttpServerConfig(path,...
    'port', 5000 ...
    , 'developerMode', true ...
    , 'defaultfile', 'index.sns' ...
    , 'app', SnisPocApp ...
    , 'networkerType', 'javaServerSocket');
  %  'javaServerSocket' 'matlabTcpipServer'
server = Simple.Net.HttpServer(config);
    
%% 
server.start().listen();
% server.startAsync();