function [t,table_header]=make_events(sub_id, task_id, run_id, onset, duration, trial_type, varargin)

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

%% make the file name
task_dir = pwd;

if ~exist(fullfile(pwd,'output'), 'dir')
    mkdir(fullfile(pwd,'output'));
end

events_tsv_name = fullfile(task_dir, 'output', ...
    ['sub-' sub_id ...
    '_task-' task_id ...
    '_run-' run_id '_events.tsv']);

%% make an event table and save

t = table(onset,duration,trial_type,varargin{:});

table_header = {};

for K = 4 : nargin
    fprintf('input #%d came from variable "%s"\n', K, inputname(K) );
    table_header{end+1} = inputname(K);
end

t.Properties.VariableNames = table_header;

writetable(t,events_tsv_name,'FileType','text','Delimiter','\t');

end