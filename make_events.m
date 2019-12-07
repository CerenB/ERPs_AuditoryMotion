fucntion = make_events(sub_id, ses_id, task_id, run_id);

%% Nancy projects
% It creates a BIDS compatible sub-01_ses-01_task-FullExample-01_events.tsv file
% This example lists all required and optional fields.
% When adding additional metadata please use CamelCase
%
% anushkab, 2018
% modified RG 201809
% modified marcobarilari 201912
%
% it requires:
%

%%
task_dir = pwd;

switch
    
    case 'open'
        
        if exist('output', 'dir') ~= 7
            mkdir('output');
        end
        
        events_tsv_name = fullfile(task_dir, output, ...
            ['sub-' sub_id ...
            '_ses-' ses_id ...
            '_task-' task_id ...
            '_run-' run_id '_events.tsv']);
        
        %% make an event table and save
        
        %% CONTAINS a set of REQUIRED and OPTIONAL columns
        %REQUIRED Onset (in seconds) of the event  measured from the beginning of
        % the acquisition of the first volume in the corresponding task imaging data file.
        % If any acquired scans have been discarded before forming the imaging data file,
        % ensure that a time of 0 corresponds to the first image stored. In other words
        % negative numbers in onset are allowed.
        onset = [0]';
        
        %REQUIRED. Duration of the event (measured  from onset) in seconds.
        % Must always be either zero or positive. A "duration" value of zero implies
        % that the delta function or event is so short as to be effectively modeled as an impulse.
        duration = [0]';
        
        %OPTIONAL Primary categorisation of each trial to identify them as instances
        % of the experimental conditions
        trial_type={' '};
        
        %OPTIONAL. Response time measured in seconds. A negative response time can be
        % used to represent preemptive responses and n/a denotes a missed response.
        response_time=[0]';
        
        %OPTIONAL Represents the location of the stimulus file (image, video, sound etc.)
        % presented at the given onset time
        stim_file={' '};
        
        %OPTIONAL Hierarchical Event Descriptor (HED) Tag.
        HED= {' '};
        
        
        %% Save table
        t = table(onset,duration,trial_type,response_time,stim_file,HED);
        
        writetable(t,events_tsv_name,'FileType','text','Delimiter','\t');
        
end

end