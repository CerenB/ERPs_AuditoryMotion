function [trial_seq_names,trial_seq] = getTrialSeq(numTrials, numTargets)

% function to create the randomization of all the conditions in the ERP -
%motion experiemnt
%
% with numTrails and percTarget it calculates the number of trials per
% condition
% 
% outputs the trial sequence with numbers (trial_seq) or with names (trial_seq_names)
%
% number assigned order:
% 1     static
% 2     mot_LRRL
% 3     mot_RLLR
% 4     Static_T
% 5     mot_LRRL_T
% 6     mot_RLLR_T

% calculate how many trials per condition dividing them in 3 chunks to help
% even randomization across experiment per condition

numTrials = numTrials/4;
numTargets = numTargets/4;

%%%%%%%%%%%%%% CB continue from here 
static = numTrials- numTargets/2;
mot_LRRL = ((numTrials- numTargets/2))/2;
mot_RLLR = ((numTrials- numTargets/2))/2;
static_T = numTargets/2;
mot_LRRL_T = numTargets/4;
mot_RLLR_T = numTargets/4;
%%%%%%%%%%%%%%
% check that all of those values are integers
if any(rem([static, mot_LRRL, mot_RLLR, static_T, mot_LRRL_T, mot_RLLR_T], 1)~=0)
    error('that combination of number of trials and percentage of target is not possible')
end

% create the three chunks of condition and randomize them and check that: 
% 1 - the target is not in the first trial
% 2 - two target are not consecutive
% 3 - there are no more them 3 same trials consecutive (less than that is impossible)

d = 1; % counter for trial number

while d < numTrials*3-2
    
    % create a sequence of trials that contains 1 thirs of all the trials
    trial_seq = [ ...
        repmat(ones,1,static),  repmat(2,1,mot_LRRL),   repmat(3,1,mot_RLLR), ...
        repmat(4,1,static_T),   repmat(5,1,mot_LRRL_T), repmat(6,1,mot_RLLR_T)];
    
    % we shuffle each chunck and concatenate them
    trial_seq = [ Shuffle(trial_seq), Shuffle(trial_seq), Shuffle(trial_seq) ];
   
    % scan through the trial sequence and checks all the conditions
    while d < length(trial_seq)-2
        
        if d == 1 && trial_seq(d) > 3 % no targets in the first trial
            d = 1;
            break
        elseif trial_seq(d) > 3 && trial_seq(d+1) > 3 % avoid 2 consecutive targets
            d = 1;
            break
            % avoid series 3 times the same conditions
        elseif trial_seq(d) ==  trial_seq(d+1) && trial_seq(d+1) ==  trial_seq(d+2) && trial_seq(d+2) ==  trial_seq(d+3)
            d = 1;
            break
        else
            d = d+1;
        end
    end
end

% rename the numbers with condition name
trial_seq_names = {};
for i = 1:length(trial_seq)
    trial_seq_names{end+1} = num2str(trial_seq(i)); %#ok<AGROW>
end

trial_seq_names(strcmpi(trial_seq_names,'1')) = {'static'};
trial_seq_names(strcmpi(trial_seq_names,'2')) = {'mot_LRRL'};
trial_seq_names(strcmpi(trial_seq_names,'3')) = {'mot_RLLR'};
trial_seq_names(strcmpi(trial_seq_names,'4')) = {'static_T'};
trial_seq_names(strcmpi(trial_seq_names,'5')) = {'mot_LRRL_T'};
trial_seq_names(strcmpi(trial_seq_names,'6')) = {'mot_RLLR_T'};

end