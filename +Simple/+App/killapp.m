function killapp()
    Simple.App.App.terminate();
    if exist('cprintf', 'file')
        cprintf('Error', 'App persistence terminated successfully.\n');
    else
        fprintf('App persistence terminated successfully.\n');
    end
end