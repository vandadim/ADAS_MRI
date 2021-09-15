%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comparison of single and multi-tasklearning for predicting
% cognitive declinebased on MRI data
% Vandad imani 2020 - 2021
% University of Eastern Finland, Finland (2020 - 2021)
% --------------------------------------------------------------
% Permission to use, copy, modify, and distribute this software 
% for any purpose and without fee is hereby granted, provided 
% that the above copyright notice appear in all copies. The 
% author and University of Eastern Finland make no representations 
% about the suitability of this software for any purpose.  
% It is provided "as is" without express or implied warranty.
% -------------------------------------------------------------

%% Preprocessing 
% Preprocessing Example

% For the preprocessing, the following scripts will need to
% be available in the Matlab path:
%   adas_prepare_data_average_sc.m
%   catSegment_job.mat
%   rdir.m
%   reorient.m
%   standard_seg.m
% Add the path of SPM 12 and CAT 12
% The standard_seg function is the first main function. It requires three
% mandatory arguments:
% dataPath   : The data path in which subjects are available.
% matFilePath: The catSegment_job path 
% outPath    : The output path
% Ther adas_prepare_data_average_sc function is the second main function. It requires three
% mandatory arguments:
% datadir{1} = '..\ADNI1screening_segmented'; % ADNI 1
% datadir{2} = '..\ADNI2screening_segmented'; % ANDI 2
% templatefn = '..\aal.nii'; % Template
% outpath    = '..\AAL;
%
addpath C:\Users\vandad\spm12
addpath C:\Users\vandad\cat12
dataPath_ADNI1      = '\Path\of\ADNI\data\with\ADNI1';
dataPath_ADNI2      = '\Path\of\ADNI\data\with\ADNI2';
outPath_ADNI1       = '\Path\of\segmented\ADNI1_Imgs';
outPath_ADNI2       = '\Path\of\segmented\ADNI2_Imgs';
matFilePath         = '\Path\of\catSegment_job.mat';

standard_seg(dataPath_ADNI1, matFilePath, outPath_ADNI1);
standard_seg(dataPath_ADNI2, matFilePath, outPath_ADNI2);
%
datadir{1} = outPath_ADNI1;
datadir{2} = outPath_ADNI2;
templatefn = '\Path\of\Template\aal.nii'; % Template
outpath    = '\Path\of\AVG_AAL';
adas_prepare_data_average_sc(datadir,templatefn,outpath);

%% Change of ADAS-Cog Score Prediction

% Install Lasso and elastic-net regularized generalized linear models (Glmnet)
% Install library for support vector machines (This used in cascade ensemble learning method)
% Install ComBat harmonization in Matlab
% Install the MALSAR (Multi-tAsk Learning via StructurAl Regularization) package which includes the MTL learning algorithms
%%%Download link is available through the Package Usage in the implementation section.%%%

% Datapath        : The directory containing data from AVG_AAL
Datapath = outpath;

%% SINGLE-TASK LEARNING

% the directory containing the mentioned packages must be added to 
% the Matlab path as follows:

addpath('\Path\of\glmnet_matlab\');
addpath('.\Path\of\libsvm-3.22\matlab\');
addpath('\Path\of\ComBatHarmonization\scripts\');

% For the Single-task learning, the following scripts will need to
% be available in the Matlab path:
%   ALL_EN.m
%   balanced_crossval.m
%   rdir.m
%%% These functions are available in ALL_EN section.

% - Single-task learning without harmonization and considering biological
% covariate
Harmonization  = 0; % Harmonization   : 0- Without data monization, 1- ComBat harmonization, 2- PLS-based domain adaptation  
Covariate      = 0; % Covariate       : 0- Without considering Age as covariate, 1-With considering Age as covariate
ALL_EN(Datapath,Harmonization,Covariate)
% - Single-task learning with harmonization and considering biological
% covariate
Harmonization  = 1;
Covariate      = 1;
ALL_EN(Datapath,Harmonization,Covariate)
% - Single-task learning with PLS-Based domain adaptation for
% harmonization without considering biological covariate
Harmonization  = 2;
Covariate      = 0;
ALL_EN(Datapath,Harmonization,Covariate)


%% Cascade Ensemble Learning 
% For the Cascade Ensemble Learning, the following scripts will need to
% be available in the Matlab path:
% Cas_EN.m
% Normalize_Fcn2.m
% balanced_crossval.m
% rdir.m
% svmTrainY.m

% - Cascade Ensemble Learning with harmonization and considering biological
% covariate
% Harmonization   : 1- ComBat harmonization, 2- PLS-based domain adaptation  
% Covariate       : 0- Without considering Age as covariate, 1-With considering Age as covariate
Harmonization  = 1;
Covariate      = 1;
Cas_EN(Datapath,Harmonization,Covariate)
% - Cascade Ensemble Learning with PLS-Based domain adaptation for
% harmonization without considering biological covariate
Harmonization  = 2;
Covariate      = 0;
Cas_EN(Datapath,Harmonization,Covariate)

%% Multi-Task learning

% the directory containing the Multi-Task learning packages must be added to 
% the Matlab path as follows:

addpath('\Path\of\MALSAR\functions\');
addpath('.\Path\of\MALSAR\utils\');

% For the Multi-Task learning, the following scripts will need to
% be available in the Matlab path:
% CrossValidation1Param.m
% CrossValidationDirty.m
% MTL_fun.m
% balanced_crossval.m
% rdir.m

% - Multi-Task learning without harmonization and considering biological
% covariate using Least Lasso formulations
% Harmonization   : 0- Without data monization, 1- ComBat harmonization, 2- PLS-based domain adaptation  
% Covariate       : 0- Without considering Age as covariate, 1-With considering Age as covariate
% Formulations    : 0- Least Lasso, 1-Joint feature selection (JFS), 2- Dirty Model, 3- Low rank assumption (LRA)

Harmonization  = 0;
Covariate      = 0;
Formulations   = 0; 
MTL_fun(Datapath,Harmonization,Covariate,Formulations)


% - Multi-Task learning using ComBat harmonization and considering 
% Age as a biological covariate using Least Lasso formulations
Harmonization  = 1;
Covariate      = 1;
Formulations   = 0; 
MTL_fun(Datapath,Harmonization,Covariate,Formulations)

% - Multi-Task learning using PLS-based domain adaptation for harmonization, 
% without considering biological covariate using Dirty Model formulations
Harmonization  = 2;
Covariate      = 0;
Formulations   = 2; 
MTL_fun(Datapath,Harmonization,Covariate,Formulations)

%% MTL-based MFS Harmonization

% For the MTL-based MFS Harmonization, the following scripts will need to
% be available in the Matlab path:
% CrossValidation1Param.m
% CrossValidationDirty.m
% MTL_6tasks.m
% balanced_crossval.m
% rdir.m

% - MTL-based MFS Harmonization using Least Lasso formulations
% Formulations    : 0- Least Lasso, 1-Joint feature selection (JFS), 2- Dirty Model, 3- Low rank assumption (LRA)
Formulations   = 0; 
MTL_6tasks(Datapath,Formulations)

% - MTL-based MFS Harmonization using Joint feature selection formulations
Formulations   = 1; 
MTL_6tasks(Datapath,Formulations)










