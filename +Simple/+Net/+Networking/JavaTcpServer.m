function [TCP,data,cleanupObj]=JavaTcpServer(action,TCP,data,config, httpServer)
persistent GlobalserverSocket;
import java.net.Socket
import java.io.*
import java.net.ServerSocket
% timeout=config.connectTimeout * 1000;
if(nargin<3), data=[]; end

switch(action)
    case 'initialize'
        try
            serverSocket = ServerSocket(data);
        catch ex
            if ~isempty(GlobalserverSocket)
                try
                    GlobalserverSocket.close;
                    serverSocket = ServerSocket(data);
                catch ex
                    error('JavaTcpServer:initialize', ['Failed to Open Server Port. ' ...
                        'Reasons: "port is still open by Matlab for instance due ' ... 
                        'to a previous crash", "Blocked by Firewall application",  ' ...
                        '"Port open in another Application", "No rights to open the port"']);
                end
            else
                rethrow(ex);
            end
        end
        
        serverSocket.setReuseAddress(true);
        timeout = 200;
        serverSocket.setSoTimeout(timeout);
        serverSocket.setPerformancePreferences(0, 1, 2);
        cleanupObj = onCleanup(@TCP.serverSocket.close);
        TCP.port = data;
        TCP.serverSocket=serverSocket;
        GlobalserverSocket=serverSocket;
        % TCP.stopwindow=stopwindow();
    case 'accept'
        while(true)
            try
                % start = tic;
                socket = TCP.serverSocket.accept;
                break;
            catch ex
                if ~isempty(ex.ExceptionObject) && isa(ex.ExceptionObject, 'java.net.SocketTimeoutException')
                    config.app.handleFutures(httpServer);
                    continue
                else
                    TCP.socket=-1;
                    return
                end
            end
        end
        TCP.socket = socket;
        TCP.remoteHost = char(socket.getInetAddress);
        TCP.outputStream = socket.getOutputStream;
        TCP.inputStream = socket.getInputStream;
    case 'read'
        data=zeros(1,1000000,'int8'); tBytes=0;
        tstart=tic;
        while(true)
            nBytes = TCP.inputStream.available;
            partdata = zeros(1, nBytes, 'int8');
            for i = 1:nBytes, partdata(i) = DataInputStream(TCP.inputStream).readByte; end
            data(tBytes+1:tBytes+nBytes) = partdata;
            tBytes=tBytes+nBytes;
            % Only exist if the buffer is empty and some request-data
            % is received, or if the time is larger then 1.5 seconds
            t=toc(tstart);
            if(isempty(partdata)&&(t>config.readEndTimeout)&&(tBytes>0)), break; end
            if(isempty(partdata)&&(t>config.readStartTimeout)), break; end
        end
        data=data(1:tBytes);
    case 'write'
        if(~isa(data,'int8')), error('TCP:input','Data must be of type int8'); end
        try
            DataOutputStream(TCP.outputStream).write(data,0,length(data));
        catch
        end
		try
			DataOutputStream(TCP.outputStream).flush;
		catch
		end
	case 'close'
        TCP.serverSocket.close;
end

function handle_figure=stopwindow()
handle_figure=figure;
set(handle_figure,'Units','Pixels');
w=get(handle_figure,'Position'); 
set(handle_figure,'Position',[w(1) w(2) 200 100]);
set(handle_figure,'Resize','off')
uicontrol('Style', 'text','String','Close Window to Shutdown Server','Position', [0 0 200 100]);

