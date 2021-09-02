% Generating Multi-task learning model for regression
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
% OUTPUT : Results available for 12, 24, and 36 Months
% Correlation and MAE between predicted ADAS and observed ADAS(NC,MCI and AD)
% Predicted value for each outer loop
% INPUT:
% Path            : The directory containing data
% Harmonization   : 0- Without data monization, 1- ComBat harmonization, 2- PLS-based domain adaptation  
% Covariate       : 0- Without considering Age as covariate, 1-With considering Age as covariate
% Formulations    : 0- Least Lasso, 1-Joint feature selection (JFS), 2- Dirty Model, 3- Low rank assumption (LRA)

% --------------------------EXAMPLE--------------------------------
% Use multi-task model for predicting without considering harmonization step
% and effect of the biological covariate.
% Datapath       = '/path/to/the/data/folder';
% Harmonization  = 0;
% Covariate      = 0;
% Formulations   = 0; % Or 1 Or 2 Or 3
% MTL_fun(Datapath,Harmonization,Covariate,Formulations)
% -----------------------------------------------------------

function MTL_fun(Path,Harmonization,Covariate,Formulations)
if ~exist('Harmonization','var')
    Harmonization = 0;
end
if ~exist('Covariate','var')
    Covariate = 0;
end
if ~exist('Formulations','var')
    Formulations = 0;
end
Months          = {'12','24','36'};
dataPath        = Path;
matFilePath     = rdir([dataPath '/*.mat']);
nuMatFile       = numel(matFilePath);
mat1            = load([dataPath '/' matFilePath(1).name]);

for Month = 1:size(Months,2)
    
    ylabel          = mat1.ADAS(:,Month+1);
    DXlabel         = mat1.Dx(:,1);
    % Handle Missing labels
    [n1,~]         = ind2sub(size(ylabel),ylabel==-1);
    ylabel(n1==1)   = [];
    DXlabel(n1==1)  = [];
    [n2,~]         = ind2sub(size(DXlabel),DXlabel==0);
    ylabel(n2==1)   = [];
    DXlabel(n2==1)  = [];
    
    %Baseline ADAS-Scores
    Base            = mat1.ADAS(:,1);
    Base(n1==1)     = [];
    Base(n2==1)     = [];
    %Calculate the changes
    NoYlabel      = ylabel-Base;%zscore(AdasChange);
    
    % Initialize output
    cor             = zeros(10,1);
    MAE             = zeros(10,1);
    results         = cell(10,3);
    results_NC      = cell(10,3);
    results_MCI     = cell(10,3);
    results_AD      = cell(10,3);
    XS_all          = [];
    
    % Number of folds
    kf = 10;
    
    
    %% Avg of reagions
    for it = 1:nuMatFile
        it
        matRegions          = load([dataPath '/' matFilePath(it).name]);
        mriData             = matRegions.aalX;
        mriData(n1==1,:)    = [];
        mriData(n2==1,:)    = [];
        fData               = double(mriData);
        XS                  = mean(fData');
        XS_all              = [XS_all;XS];
    end
    XS_all = XS_all';
    %% ComBat Harmonization
    if Harmonization==1 && Covariate ==1
        
        site_AD             = matRegions.ADNI;
        site_AD(n1==1)      = [];
        site_AD(n2==1)      = [];
        Age_AD              = matRegions.age;
        Age_AD(n1==1)       = [];
        Age_AD(n2==1)       = [];
        Data                = XS_all';
        Batch               = site_AD';
        MOD                 = Age_AD;
        data_harmonized     = combat(Data, Batch, MOD, 1);
        XS_all              =  data_harmonized';
    elseif Harmonization==1 && Covariate ==0
        
        site_AD             = matRegions.ADNI;
        site_AD(n1==1)      = [];
        site_AD(n2==1)      = [];
        Data                = XS_all';
        Batch               = site_AD';
        MOD                 = [];
        data_harmonized     = combat(Data, Batch, MOD, 1);
        XS_all              =  data_harmonized';
    end
    %% PLS-Based domain adaptation
    if Harmonization==2 && Covariate ==1
        
        site_AD             = matRegions.ADNI;
        site_AD(n1==1)      = [];
        site_AD(n2==1)      = [];
        Age_AD              = matRegions.age;
        Age_AD(n1==1)       = [];
        Age_AD(n2==1)       = [];
        Response_Variable   = [site_AD,Age_AD];
        Data                = XS_all;
        [~,~,XS1,~]      = plsregress(Data,Response_Variable,20); % Number of component(Here= 20) can be find in the inner CV loop
        XS_all              = XS1;
    elseif Harmonization==2 && Covariate ==0
        
        site_AD             = matRegions.ADNI;
        site_AD(n1==1)      = [];
        site_AD(n2==1)      = [];
        Response_Variable   = [site_AD,Age_AD];
        Data                = XS_all;
        [~,~,XS1,~]      = plsregress(Data,Response_Variable,20); % Number of component(Here= 20) can be find in the inner CV loop
        XS_all              = XS1;
    end
    %XS_all = zscore(XS_all,[ ],2);
    XS_all = [XS_all ones(size(XS_all, 1), 1)]; % Add a bias column to the data for each task to learn the bias
    %% Learning stage
    
    for h =1:10
        h
        balancd_CV1 = balanced_crossval(NoYlabel,kf,[]);
        
        Pred_NC=[];
        Pred_MCI=[];
        Pred_AD=[];
        Act_NC=[];
        Act_MCI=[];
        Act_AD=[];
        INDX_NC  = [];
        INDX_MCI = [];
        INDX_AD  = [];
        
        
        for i = 1:kf
            
            X_Tr            = cell(1,3);
            Y_Tr            = cell(1,3);
            X_Ts            = cell(1,3);
            Y_Ts            = cell(1,3);
            
            % TRAIN Data
            train1_indx     = find(balancd_CV1~= i);
            train1_label    = NoYlabel(balancd_CV1~= i);
            train_set       = XS_all(train1_indx,:);
            train_set       = zscore(train_set);
            DX_Train        = DXlabel(balancd_CV1~= i);
            
            DX_Tr_NC        = find(DX_Train == 1);
            DX_Tr_MCI       = find(DX_Train == 2);
            DX_Tr_AD        = find(DX_Train == 3);
            
            X_Tr{1,1}       = train_set(DX_Tr_NC,:);
            X_Tr{1,2}       = train_set(DX_Tr_MCI,:);
            X_Tr{1,3}       = train_set(DX_Tr_AD,:);
            
            Y_Tr{1,1}       = train1_label(DX_Tr_NC);
            Y_Tr{1,2}       = train1_label(DX_Tr_MCI);
            Y_Tr{1,3}       = train1_label(DX_Tr_AD);
            
            % TEST Data
            test1_label     = NoYlabel(balancd_CV1== i);
            test1_indx      = find(balancd_CV1== i);
            test_set        = XS_all(test1_indx,:);
            test_set        = zscore(test_set);
            DX_Test         = DXlabel(balancd_CV1== i);
            
            DX_Ts_NC        = find(DX_Test == 1);
            DX_Ts_MCI       = find(DX_Test == 2);
            DX_Ts_AD        = find(DX_Test == 3);
            
            X_Ts{1,1}       = test_set(DX_Ts_NC,:);
            X_Ts{1,2}       = test_set(DX_Ts_MCI,:);
            X_Ts{1,3}       = test_set(DX_Ts_AD,:);
            
            Y_Ts{1,1}       = test1_label(DX_Ts_NC);
            Y_Ts{1,2}       = test1_label(DX_Ts_MCI);
            Y_Ts{1,3}       = test1_label(DX_Ts_AD);
            
            
            INDXNC             = test1_indx(DX_Ts_NC);
            INDXMCI            = test1_indx(DX_Ts_MCI);
            INDXAD             = test1_indx(DX_Ts_AD);
            
            
            %% Model-Parameters
            % Least_Lasso
            eval_func_str = 'eval_MTL_mse';
            higher_better = false; %
            cv_fold = 10;
            opts = [];
            opts.maxIter    = 2000;
            opts.tol    = 10^-14;
            opts.tFlag  = 2;
            opts.init   = 2;
            if Formulations==0 % Least Lasso
                opts.rho_L2 = 10; %Regularization
                param_range = [0.001 0.01 0.1 1 10 40 45 50 55 60 90 95 100 150 200 1000 10000];
                best_param = CrossValidation1Param( X_Tr, Y_Tr, 'Least_Lasso', opts, param_range,cv_fold, eval_func_str, higher_better);
                [W1, ~] = Least_Lasso(X_Tr, Y_Tr, best_param, opts);
            elseif Formulations==1 % JFS
                opts.rho_L2 = 6;
                param_range = [0.001 0.01 0.1 1 10 90 100 110 140 145 150 155 160 200 1000 10000];
                best_param = CrossValidation1Param( X_Tr, Y_Tr, 'Least_L21', opts, param_range,cv_fold, eval_func_str, higher_better);
                [W1, ~] = Least_L21(X_Tr, Y_Tr, best_param, opts);
            elseif Formulations==2 % Dirty Model
                eval_func_str = 'eval_MTL_rmse';
                opts.lFlag      = 1;
                lambda1_range =  [300 350 380 385 390 395 400 500 1000];
                lambda2_range =  [300 350 380 385 390 395 400 500 1000];
                [ best_lambda1, best_lambda2, ~] = CrossValidationDirty( X_Tr, Y_Tr, 'Least_Dirty', opts, lambda1_range, lambda2_range,cv_fold, eval_func_str);
                [W1, ~, ~, ~] = Least_Dirty(X_Tr, Y_Tr, best_lambda1, best_lambda2, opts);
            elseif Formulations==3 % LRA
                eval_func_str = 'eval_MTL_rmse';
                opts.rho_L2 = 38;
                param_range = [90 95 100 200 300 400 500 600 650 665 670 675 700 1000 10000];
                best_param = CrossValidation1Param( X_Tr, Y_Tr, 'Least_Trace', opts, param_range,cv_fold, eval_func_str, higher_better);
                [W1, ~] = Least_Trace(X_Tr, Y_Tr, best_param, opts);
            end
            % CHeck the size of X
            pred_label_NC       = X_Ts{1,1}*W1(:,1);
            pred_label_MCI      = X_Ts{1,2}*W1(:,2);
            pred_label_AD       = X_Ts{1,3}*W1(:,3);
            
            Act_NC        = [Act_NC;Y_Ts{1,1}];
            Fold_NC{i,1}        = Y_Ts{1,1};
            Act_MCI       = [Act_MCI;Y_Ts{1,2}];
            Fold_MCI{i,1}       = Y_Ts{1,2};
            Act_AD        = [Act_AD;Y_Ts{1,3}];
            Fold_AD{i,1}        = Y_Ts{1,3};
            
            Pred_NC     = [Pred_NC;pred_label_NC];
            Fold_NC{i,2}        = pred_label_NC;
            Pred_MCI    = [Pred_MCI;pred_label_MCI];
            Fold_MCI{i,2}       = pred_label_MCI;
            Pred_AD     = [Pred_AD;pred_label_AD];
            Fold_AD{i,2}        = pred_label_AD;
            
            INDX_NC             = [INDX_NC;INDXNC'];
            INDX_MCI            = [INDX_MCI;INDXMCI'];
            INDX_AD             = [INDX_AD;INDXAD'];
            
        end
        %% Results
        
        act_label_All       = [Act_NC;Act_MCI;Act_AD];
        pred_label_All      = [Pred_NC;Pred_MCI;Pred_AD];
        INDX_ALL            = [INDX_NC;INDX_MCI;INDX_AD];
        cor(h)              = corr(act_label_All,pred_label_All);
        cor_s(h)            = corr(act_label_All,pred_label_All,'type','Spearman');
        MAE(h)              = mean(abs(act_label_All - pred_label_All));
        
        results{h,1}        = act_label_All;
        results{h,2}        = pred_label_All;
        results{h,3}        = INDX_ALL;
        
        
        CorNC(h)            = corr(Act_NC,Pred_NC);
        MAE_NC(h)           = mean(abs(Act_NC - Pred_NC));
        results_NC{h,1}     = Act_NC;
        results_NC{h,2}     = Pred_NC;
        results_NC{h,3}     = INDX_NC;
        
        CorMCI(h)           = corr(Act_MCI,Pred_MCI);
        MAE_MCI(h)           = mean(abs(Act_MCI-Pred_MCI));
        results_MCI{h,1}     = Act_MCI;
        results_MCI{h,2}     = Pred_MCI;
        results_MCI{h,3}    = INDX_MCI;
        
        CorAD(h)            = corr(Act_AD,Pred_AD);
        MAE_AD(h)           = mean(abs(Act_AD-Pred_AD));
        results_AD{h,1}     = Act_AD;
        results_AD{h,2}     = Pred_AD;
        results_AD{h,3}     = INDX_AD;
        Fold_NC_H{h,1}      = Fold_NC;
        Fold_MCI_H{h,1}     = Fold_MCI;
        Fold_AD_H{h,1}      = Fold_AD;
    end
    save(['Results_',Months{Month},'_Months.mat'],'results','results_NC','results_MCI','results_AD','cor','MAE','cor_s','CorNC','CorMCI','CorAD','MAE_NC','MAE_MCI','MAE_AD','Fold_NC_H','Fold_MCI_H','Fold_AD_H');
end
end
