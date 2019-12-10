%function AudMotion_sEEG

% Original Script Written by Sam Weiller to localize MT+/V5
% Adapted by M.Rezk to localize MT/MST (Huk,2002)
% Simplify the ALocaliser fmri experiment for ERPs

% simply run the script and press enter instead of specifying the
% SubjectName & provide run# to be savedin the logfile, and provide the
% length trials/duration of exp (options: 1-2-3)


% NOTES:
% when the response is given while the sound is played, it can be
% understood in the logfile, because of the time stamp.

clear
clc
PsychPortAudio('Close');

tic

%% set trial or real experiment
% device = 'eeg'; % any sound card, triggers through parallel port
% device = 'RME_RCAtrig'; % works with RME sound card and sends one trigger value through RCA cable (trigger box)
device = 'trial'; % any sound card, no triggers (parallel port not open)

fprintf('Connected Device is %s \n\n',device);

% adjust the amp according to the participant
% multiply the audio by this value to decrease the volume
new_amp = 0.2;

%after everything is ready, wait a bit to initiate sound playing loop
Init_pause = 3;



fprintf('Connected Device is %s \n\n',device);
%% Start me up
SubjName = 'test';

Run = input('\nrun n.: ','s');
if isempty(Run)
    Run=99;
end

task_id = 'AudERPs';

% here is prompt a multiverse scenario in witch you can choos n. of trials
% and therefore the length of the experiment
fprintf('\n\n case 1 - 54 trials per condition (Motion & Static) + ~10%% targets (n.12) \n          for ~5 min, to repeat at least 2 times\n')
fprintf('\n case 2 - 40 trials per condition (Motion & Static) + ~9%% targets (n.8) \n          for ~4 min, to repeat at least 3 times\n')
fprintf('\n case 3 - 28 trials per condition (Motion & Static) + ~12%% targets (n.8) \n          for ~3 min, to repeat at least 4 times\n\n')

expLength = input('length of th exp. [1 - 2 - 3]: ','s');
fprintf('\n')


%% Create log output(s)

%logfile name for .tsv (for this script only)
DateFormat = 'yyyy_mm_dd_HH_MM';
Filename = fullfile(pwd, 'output', ...
    ['sub-' SubjName, ...
    '_run-' Run, ...
    '_case-n-' expLength, ...
    '_' datestr(now, DateFormat) '.tsv']);

% prepare for the output
% ans 7 means that a directory exist
if exist('output', 'dir') ~= 7
    mkdir('output');
end

% open a tsv file to write the output (for this script only)
fid = fopen(Filename, 'a');
fprintf(fid, 'SubjID\tExp_trial\tCondition\tSoundfile\tTarget\tTrigger\tISI\tEvent_start\tEvent_end\tEvent_duration\tResponse\tRT\n');

fprintf('Auditory ERPs \n\n')

%% Experiment Parametes
freq = 44100;

switch str2num(expLength)

    case 1
        % number of trials
        numEvents = 120;
        % n of target trials
        numTargets = 12;
    case 2
        numEvents = 88;
        numTargets = 8;
    case 3
        numEvents = 64;
        numTargets = 8;
end

% creating jitter with uniform distribution around 1 average is 1.5 (after
%1s sound, 1s min gap and max 2s)
jitter = rand(1,numEvents);

% CONSIDER MAKING JITTER BALANCED ACROSS CONDITIONS

% a vector of interstimulus intervals for each event
ISI = 1 + jitter;

%% Experimental Design

% pseudorandomized events order: 2 MOTION + 1 static + 10% of targers
[Event_names, Event_order]= getTrialSeq(numEvents,numTargets,expLength);

% reassign it in case pseudorandomization provided less trial number
numEvents = length(Event_order);

soundfiles = {...
    'rms_static_1s',...
    'rms_mot_LR_1s',...
    'rms_mot_RL_1s',...
    'rms_static_2s',...
    'rms_mot_LR_2s',...
    'rms_mot_RL_2s'};

numcondition = length(soundfiles);

condition = {...
    'static',...
    'motion',...
    'motion',...
    'static',...
    'motion',...
    'motion'};

isTarget = [0 0 0 1 1 1];


%% Open parallel port
if strcmp(device,'eeg')
    openparallelport('D010');
end

%% InitializePsychAudio;

% load all the sounds & lower the amplitude of the sounds
% lower the amp is crucial for the in-ear headphone set!
for icon = 1:numcondition

    chosen_file{icon} = [soundfiles{icon},'.wav'];
    filename = fullfile('stimuli',SubjName,chosen_file{icon});
    [SoundData{icon},~]=audioread(filename);
    SoundData{icon} = SoundData{icon} .* new_amp;
    SoundData{icon} = SoundData{icon}';

end

InitializePsychSound(1);

% open audio port
audio_config.freq = freq;
audio_config.sound =  SoundData{1}; % test sound
audio_config = triggerSend('open', device, audio_config);


%% Experiment Start
% Wait for the "SPACE" key with KbCheck in the subfuction.
pressSpace4me();

% get time point at the beginning of the experiment (machine time)
experimentStartTime = GetSecs();

%initial pause
WaitSecs(Init_pause);


%% Loop starts
eventOnsets =       zeros(1,numEvents);
eventEnds =         zeros(1,numEvents);
eventDurations =    zeros(1,numEvents);
responses =         {};
playTime =          zeros(1,numEvents);
conditions =        {};
isTargets =         zeros(1,numEvents);

for iEvent = 1:numEvents

    startEvent = GetSecs();
    responseKey  = 'NA';
    responseTime = 0;

    conditions{end+1,1} = condition(Event_order(iEvent));

    % get the onset time
    eventOnsets(iEvent)=GetSecs-experimentStartTime;
    % get the condition of the event (motion or static)
    timeLogger(iEvent).condition = condition(Event_order(iEvent));
    % get the name of the event
    timeLogger(iEvent).names = soundfiles(Event_order(iEvent));
    % get the ISI of the event
    timeLogger(iEvent).ISI = ISI(iEvent);

    % Load the chosen sound
    Sound = SoundData{Event_order(iEvent)};


    % fill the buffer
    audio_config.sound =  Sound;
    audio_config = triggerSend('fillBuffer', device, audio_config);


    % start sound and send the trigger
    trigger = Event_order(iEvent);

    audio_config = triggerSend('start', device, audio_config);

    playTime(1,iEvent) = audio_config.playTime ;

    % log the start time of the sound
    timeLogger(iEvent).startTime = playTime(1,iEvent) - experimentStartTime; %#ok<*SAGROW>


    % wait for the ISI and register the responseKey
    while (GetSecs-(playTime(1,iEvent)+(length(Sound)/freq))) <= (ISI(iEvent))

        [keyIsDown, secs, keyCode] = KbCheck(-1);

        if keyIsDown


            responseKey = KbName(find(keyCode));
            responseTime = secs - experimentStartTime;

            % ecs key press - stop playing the sounds//script
            if strcmp(responseKey,'DELETE')==1

                % If the script is stopped while a sequence is being
                % played, it close psychport audio and sends trigger a
                % trigger if connected to EEG trigger
                audio_config = triggerSend('abort', device, audio_config);

                return

            end

        end
    end

    %calculate timings
    eventEnds(iEvent)=GetSecs-experimentStartTime;
    eventDurations(iEvent)=eventEnds(iEvent)-eventOnsets(iEvent);

    % log response and time
    responses{end+1} = responseKey;
    responsesTime(iEvent) = responseTime;
    isTargets(iEvent) = isTarget(Event_order(iEvent));

    % get the total trial duration and all for structure
    timeLogger(iEvent).length  = eventDurations(iEvent);
    % get the time for the block end
    timeLogger(iEvent).endTime = eventEnds(iEvent);
    timeLogger(iEvent).responseTime = responsesTime(iEvent);
    timeLogger(iEvent).response = responses(iEvent);
    timeLogger(iEvent).isTarget = isTarget(Event_order(iEvent));
    timeLogger(iEvent).soundcode = trigger;

    %logfile incase the script stopped
    fprintf(fid,'%s\t %d\t %s\t %s\t %d\t %d\t %f\t %f\t %f\t %f\t %s\t %f\n',...
        SubjName, iEvent, condition{Event_order(iEvent)}, soundfiles{Event_order(iEvent)}, ...
        isTarget(Event_order(iEvent)), trigger, ISI(iEvent), ...
        timeLogger(iEvent).startTime, eventEnds(iEvent), eventDurations(iEvent), ...
        responseKey, responseTime);


end


%% Save the results ('names','onsets','ends','duration') of each block
names     = cell(length(timeLogger),1);
onsets    = zeros(length(timeLogger),1);
ends      = zeros(length(timeLogger),1);
durations = zeros(length(timeLogger),1);

for i=1:length(timeLogger)
    names(i,1)     = timeLogger(i).names;
    onsets(i,1)    = timeLogger(i).startTime;
    ends(i,1)      = timeLogger(i).endTime;
    durations(i,1) = timeLogger(i).length;
end

condition = conditions';
Events_order = Event_order';
target = isTargets';
isi = ISI';
eventEnd = eventEnds';
response = responses';
responseTime = responsesTime';

[ t, table_header ] = make_events(SubjName, task_id, Run, onsets, durations, conditions, ...
    names, ...
    target, ...
    Events_order, ...
    isi, ...
    eventEnd, ...
    response, ...
    responseTime);


%% Close the port
audio_config = triggerSend('close', device, audio_config);

% Take the total exp time to printout
Experiment_duration = GetSecs - experimentStartTime;


%% Save a mat Log file
% Onsets & durations are saved in seconds.
save(fullfile(pwd, 'output', ['logFileFull_', SubjName, '_run-' Run,'_case-n-' expLength,'.mat']));
save(fullfile(pwd, 'output', ['logFile_', SubjName, '_run-' Run,'_case-n-' expLength,'.mat']), ...
    'names', 'onsets', 'durations', 'ends', 'responseTime', ...
    'responseKey', 'Experiment_duration', 'playTime','timeLogger');

%close the logfile
fclose(fid);

%take the last time
expTime = toc;


%% print the duration of the exp
fprintf('\nSequence IS OVER!!\n');
fprintf('\n==================\n\n');

fprintf('\nyou have tested %d trials for STATIC and %d trials for MOTION conditions\n\n', ...
    (numEvents-numTargets)/2, (numEvents-numTargets)/2);

fprintf('\nexp. duration was %f minutes\n\n', expTime/60);
