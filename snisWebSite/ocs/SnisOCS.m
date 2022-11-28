if exist('server', 'var') && server.isActive
   server.stop();
   delete(server);
end

path = which(mfilename());
path = path(1:find(path == '/', 1, 'last') - 1);
path = path(1:find(path == '/', 1, 'last'));

pool = gcp('nocreate');
if isempty(pool)
    pool = parpool('local');
end
pool.IdleTimeout = Inf;
    
config = Simple.Net.HttpServerConfig(path,...
    'port', 5000 ...
    , 'developerMode', true ...
    , 'defaultfile', 'index.sns' ...
    , 'app', SnisOcsApp ...
    , 'networkerType', 'javaServerSocket');
  %  'javaServerSocket' 'matlabTcpipServer'
server = Simple.Net.HttpServer(config);
    
%% 
%server.start().listen();
server.startAsync();