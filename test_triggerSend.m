% script to test trigger wrapper function

clear all;  %#ok<CLALL>
clc

freq = 44100;

% create a 1 second pure tone to test;
sound = repmat(sin(2*pi*440*(1:freq)/freq), 2, 1);

audio_config.freq = 44100; 
device = 'RME_RCAtrig'; % 'trial' 'eeg'
audio_config.sound = sound; % 

audio_config = triggerSend('open', device, audio_config);

WaitSecs(2)

audio_config = triggerSend('fillBuffer', device, audio_config);

audio_config = triggerSend('start', device, audio_config);

WaitSecs(2)

audio_config = triggerSend('close', device, audio_config);