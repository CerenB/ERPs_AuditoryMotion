function pressSpace4me

fprintf('\nYou have to press SPACE to start the experiment! <3\n');
keyCode = [];
responseKey = [];
while 1
    
    WaitSecs(0.1);
    [keyIsDown, secs, keyCode] = KbCheck(-1);
    
    if keyIsDown
        responseKey = KbName(find(keyCode));
        if strcmp(responseKey,'space')
            fprintf('starting the experiment....\n');
            break
        end
    end
    
    %     fprintf('pressed key is %s\n',responseKey);
    %     fprintf('keyCode is %s\n',responseKey);
end

end

