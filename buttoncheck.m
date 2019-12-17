function [responseKey, responseTime]= buttoncheck(deviceIndex)

if nargin < 1
  deviceIndex = [];
end


% Displays the number of seconds that have elapsed when the user presses a
% key.
escapeKey = KbName('DELETE');
startSecs = GetSecs;

KbQueueCreate(deviceIndex);
KbQueueStart(deviceIndex);

while 1
    [ pressed, firstPress]=KbQueueCheck(deviceIndex);
    timeSecs = firstPress(find(firstPress)); %#ok<FNDSB>
    if pressed
        
        %pressed response key
        responseKey = KbName(min(find(firstPress)));
        responseTime = timeSecs - startSecs;
        
        if firstPress(escapeKey)
            break;
        end
	end
end
KbQueueRelease(deviceIndex);

end




% function buttoncheck(deviceIndex)
% 
% % check the button presses while the sound file is been played
% pathname = '/Users/cerenbattal/Documents/GitHub/sEEG_exp_AuditoryMotion/input_FPAS';
% Soundfile = fullfile(pathname,'Type1_SUB001_A.wav');
% 
% 
% % set wav file features
% numchannel = 1;
% freq = 44100;
% 
% % read the .wav files
% [SoundData,~]=audioread(Soundfile);
% SoundData = SoundData';
% %% initiate sounds
% 
% InitializePsychSound(1);
% % open audio port
% pahandle = PsychPortAudio('Open',[],[],1,freq,numchannel);
% 
% %load the .wav file into the buffer
% PsychPortAudio('FillBuffer',pahandle,SoundData);                        
% 
% % play the sound
% playTime = PsychPortAudio('Start', pahandle, [],[],1);
% 
% %% key press check
% % Prints a list of keys that were pressed while other code was executing
% 
% % Report time of keypress, using KbQueueCheck.
% record_keypress(deviceIndex);
% WaitSecs(0.5);
% 
% 
% %close audio port
% PsychPortAudio('Close', pahandle);
% end