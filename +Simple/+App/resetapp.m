function resetapp()
    Simple.App.App.reset();
	if exist('cprintf', 'file')
        cprintf('Comments', 'App persistence reset successfully.\n');
    else
        fprintf('App persistence reset successfully.\n');
    end
end