if exist('server', 'var') && server.isActive
   server.stop();
   delete(server);
end

% path = which(mfilename());
% path = path(1:find(path == '/', 1, 'last') - 1);
% path = path(1:find(path == '/', 1, 'last'));

pool = gcp('nocreate');
if isempty(pool)
    pool = parpool('local');
end
pool.IdleTimeout = Inf;
    
% HACK: I couldn't figure out how the config works, so I bypassed it
%config = Simple.Net.HttpServerConfig(path,
config = Simple.Net.HttpServerConfig('.',...
    'port', 5000 ...
    , 'developerMode',  true ...
    , 'defaultfile',    'index.sns' ...
    , 'app',            obs.SnisOcsApp ...
    , 'supportSessions', false ...
    , 'networkerType',  'javaServerSocket');
  %  'javaServerSocket' 'matlabTcpipServer'
server = Simple.Net.HttpServer(config);
    
%% 
server.start().listen();
%server.startAsync();