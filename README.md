# Auditory motion (s)EEG - ERP and FPAS



## FPAS

Script written by Francesca Barbero to run a long audio file (sequence).

Stimuli:

- 4 motion direction (upward, downward, leftward, rightward) recorder from LePoulpe

- length in time of the single stimulus: 500 ms

- Target: Sequence1 - Left ; Sequence2 - Right

### Task

Detect the lower amplitude direction

## ERP

Adapted from Mohamed Rezk 'ALocaliser fMRI experiment' in order to be run in (s)EEG

**Press `ESC` to interrupt the experiment when a response is expected**

It can be run with 3 different lengths that are prompted at the begging after the experiment is launched:

- case 1 - 54 trials per condition (Motion & Static) + ~10% targets (n.12) for ~5 min, to repeat at least 2 times

- case 2 - 40 trials per condition (Motion & Static) + ~9% targets (n.8) for ~4 min, to repeat at least 3 times

- case 3 - 28 trials per condition (Motion & Static) + ~12%% targets (n.8) for ~3 min, to repeat at least 4 times

### Task

Detect the longer audio file 

### output

The script automatically saves a `.tsv` file with inof about time logs, responses, condition, etc. + 2 `.mat` files with the variables from the workspace.

### Debug mode

Run the script without specifying `SubjName` and `Run`. By default it runs in "trial" mode.

Specify in line 15 if it is connected to EEG system, *for debug mode see below:*

```matlab
%% set trial or real experiment
% device = 'eeg';
device = 'trial';
```
