%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Marzieh 2017
% Edited by Vandad 2021

% These run on CAT12.

% Matlab version 8.3
% SPM12 version 6906
% Cat12 version 1207 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NumImg        = Number of images to run
% dataPath      = '\Path\of\ADNI\data\with\ADNI'
% outPath       = '\Path\of\segmented\Imgs'
% matFilePath   = '\Path\of\catSegment_job.mat'
% nRun          : Number of iterations


function standard_seg(dataPath, matFilePath, outPath, nRun)

%% Original Values
imgs_dir = rdir(dataPath);
numImg   = length(imgs_dir);
jobfile  = importdata (matFilePath);
jobs     = repmat(jobfile, 1, nRun);
inputs   = cell(0, nRun);

%% run simulation
jobs{1}.spm(1).tools(1).cat(1).estwrite(1).data = cell(nRun,1);  % data is column cell
%% Standardize and Segmentation
for crun = 1:numImg
    P    = imgs_dir(crun).name;
    orientedImg = reorient(P,outPath,crun);
    jobs{1}.spm(1).tools(1).cat(1).estwrite(1).data{crun,1}= orientedImg.fname;
    spm('defaults', 'FMRI');
    spm_jobman('run',jobs,inputs{:});    
end

