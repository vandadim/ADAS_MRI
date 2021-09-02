% Multi-task learning based harmonization model for regression
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
% Formulations    : 0- Least Lasso, 1-Joint feature selection (JFS), 2- Dirty Model, 3- Low rank assumption (LRA)

% --------------------------EXAMPLE--------------------------------
% Use MTL-based Harmonization for predicting 
% Datapath       = '/path/to/the/data/folder';
% Formulations   = 0; % Or 1 Or 2 Or 3
% MTL_6tasks(Datapath,Formulations)
% -----------------------------------------------------------

function MTL_6tasks(Path,Formulations)

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
    site_AD         = matRegions.ADNI;
    site_AD(n1==1)  = [];
    site_AD(n2==1)  = [];
    XS_all = [XS_all ones(size(XS_all, 1), 1)];
    
    %% Learning stage
    for h =1:10
        h
        balancd_CV1 = balanced_crossval(NoYlabel,kf,[]);
        
        Pred_NC_1   = [];
        Pred_MCI_1  = [];
        Pred_AD_1   = [];
        
        Pred_NC_2   = [];
        Pred_MCI_2  = [];
        Pred_AD_2   = [];
        
        Act_NC_1  = [];
        Act_MCI_1 = [];
        Act_AD_1  = [];
        
        Act_NC_2  = [];
        Act_MCI_2 = [];
        Act_AD_2  = [];
        
        INDX_NC_1       = [];
        INDX_MCI_1      = [];
        INDX_AD_1       = [];
        
        INDX_NC_2       = [];
        INDX_MCI_2      = [];
        INDX_AD_2       = [];
        
        Num_task        = 6;
        for i = 1:kf
            i
            if Month == 3
                Num_task        = 5;
            end
                
            X_Tr            = cell(1,Num_task);
            Y_Tr            = cell(1,Num_task);
            X_Ts            = cell(1,Num_task);
            Y_Ts            = cell(1,Num_task);
            
            % TRAIN Data
            train1_indx     = find(balancd_CV1~= i);
            train1_label    = NoYlabel(balancd_CV1~= i);
            train_set       = XS_all(train1_indx,:);
            
            SITE_Train      = site_AD(balancd_CV1~= i);
            DX_Tr_1         = find(SITE_Train == 1);
            DX_Tr_2         = find(SITE_Train == 2);
            DX_Train        = DXlabel(balancd_CV1~= i);
            DX_Train_1      = DX_Train(DX_Tr_1);
            DX_Train_2      = DX_Train(DX_Tr_2);
            
            DX_Tr_NC_1        = find(DX_Train_1 == 1);
            DX_Tr_MCI_1       = find(DX_Train_1 == 2);
            DX_Tr_AD_1        = find(DX_Train_1 == 3);
            
            DX_Tr_NC_2        = find(DX_Train_2 == 1);
            DX_Tr_MCI_2       = find(DX_Train_2 == 2);
            if Num_task~=5
                DX_Tr_AD_2        = find(DX_Train_2 == 3);
            end
            
            X_Tr{1,1}       = train_set(DX_Tr_NC_1,:);
            X_Tr{1,2}       = train_set(DX_Tr_MCI_1,:);
            X_Tr{1,3}       = train_set(DX_Tr_AD_1,:);
            
            X_Tr{1,4}       = train_set(DX_Tr_NC_2,:);
            X_Tr{1,5}       = train_set(DX_Tr_MCI_2,:);
            if Num_task~=5
                X_Tr{1,6}       = train_set(DX_Tr_AD_2,:);
            end
            
            
            Y_Tr{1,1}       = train1_label(DX_Tr_NC_1);
            Y_Tr{1,2}       = train1_label(DX_Tr_MCI_1);
            Y_Tr{1,3}       = train1_label(DX_Tr_AD_1);
            
            Y_Tr{1,4}       = train1_label(DX_Tr_NC_2);
            Y_Tr{1,5}       = train1_label(DX_Tr_MCI_2);
            if Num_task~=5
                Y_Tr{1,6}       = train1_label(DX_Tr_AD_2);
            end
            
            
            % TEST Data
            test1_label     = NoYlabel(balancd_CV1== i);
            test1_indx      = find(balancd_CV1== i);
            test_set        = XS_all(test1_indx,:);
            SITE_Test       = site_AD(balancd_CV1== i);
            DX_Test         = DXlabel(balancd_CV1== i);
            
            DX_test_NC_1 = find(DX_Test == 1&SITE_Test == 1);
            DX_test_NC_2 = find(DX_Test == 1&SITE_Test == 2);
            DX_test_MCI_1 = find(DX_Test == 2&SITE_Test == 1);
            DX_test_MCI_2 = find(DX_Test == 2&SITE_Test == 2);
            DX_test_AD_1 = find(DX_Test == 3&SITE_Test == 1);
            if Num_task~=5
                DX_test_AD_2 = find(DX_Test == 3&SITE_Test == 2);
            end
            
            
            
            X_Ts{1,1}       = test_set(DX_test_NC_1,:);
            X_Ts{1,2}       = test_set(DX_test_MCI_1,:);
            X_Ts{1,3}       = test_set(DX_test_AD_1,:);
            
            X_Ts{1,4}       = test_set(DX_test_NC_2,:);
            X_Ts{1,5}       = test_set(DX_test_MCI_2,:);
            if Num_task~=5
                X_Ts{1,6}       = test_set(DX_test_AD_2,:);
            end
            
            
            Y_Ts{1,1}       = test1_label(DX_test_NC_1);
            Y_Ts{1,2}       = test1_label(DX_test_MCI_1);
            Y_Ts{1,3}       = test1_label(DX_test_AD_1);
            
            Y_Ts{1,4}       = test1_label(DX_test_NC_2);
            Y_Ts{1,5}       = test1_label(DX_test_MCI_2);
            if Num_task~=5
                Y_Ts{1,6}       = test1_label(DX_test_AD_2);
            end
            
            
            INDXNC_1             = test1_indx(DX_test_NC_1);
            INDXMCI_1            = test1_indx(DX_test_MCI_1);
            INDXAD_1             = test1_indx(DX_test_AD_1);
            
            INDXNC_2             = test1_indx(DX_test_NC_2);
            INDXMCI_2            = test1_indx(DX_test_MCI_2);
            if Num_task~=5
                INDXAD_2             = test1_indx(DX_test_AD_2);
            end
            
            
            
            
            %% Model-Parameters
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
            
            pred_label_NC_1       = X_Ts{1,1}*W1(:,1);
            pred_label_MCI_1      = X_Ts{1,2}*W1(:,2);
            pred_label_AD_1       = X_Ts{1,3}*W1(:,3);
            
            pred_label_NC_2       = X_Ts{1,4}*W1(:,4);
            pred_label_MCI_2      = X_Ts{1,5}*W1(:,5);
            if Num_task~=5
                pred_label_AD_2       = X_Ts{1,6}*W1(:,6);
            end
            
            
            Act_NC_1        = [Act_NC_1;Y_Ts{1,1}];
            INDX_NC_1             = [INDX_NC_1;INDXNC_1'];
            Fold_NC_1{i,1}        = Y_Ts{1,1};
            
            Act_MCI_1       = [Act_MCI_1;Y_Ts{1,2}];
            INDX_MCI_1            = [INDX_MCI_1;INDXMCI_1'];
            Fold_MCI_1{i,1}       = Y_Ts{1,2};
            
            Act_AD_1        = [Act_AD_1;Y_Ts{1,3}];
            INDX_AD_1             = [INDX_AD_1;INDXAD_1'];
            Fold_AD_1{i,1}        = Y_Ts{1,3};
            
            
            % SCAN 2
            Act_NC_2        = [Act_NC_2;Y_Ts{1,4}];
            INDX_NC_2             = [INDX_NC_2;INDXNC_2'];
            Fold_NC_2{i,1}        = Y_Ts{1,4};
            
            Act_MCI_2       = [Act_MCI_2;Y_Ts{1,5}];
            INDX_MCI_2            = [INDX_MCI_2;INDXMCI_2'];
            Fold_MCI_2{i,1}       = Y_Ts{1,5};
            
            if Num_task~=5
                Act_AD_2        = [Act_AD_2;Y_Ts{1,6}];
                INDX_AD_2             = [INDX_AD_2;INDXAD_2'];
                Fold_AD_2{i,1}        = Y_Ts{1,6};
            end
            
            
            Pred_NC_1     = [Pred_NC_1;pred_label_NC_1];
            Fold_NC_1{i,2}        = pred_label_NC_1;
            Pred_MCI_1    = [Pred_MCI_1;pred_label_MCI_1];
            Fold_MCI_1{i,2}       = pred_label_MCI_1;
            Pred_AD_1     = [Pred_AD_1;pred_label_AD_1];
            Fold_AD_1{i,2}        = pred_label_AD_1;
            
            % SCAN 2
            Pred_NC_2     = [Pred_NC_2;pred_label_NC_2];
            Fold_NC_2{i,2}        = pred_label_NC_2;
            Pred_MCI_2    = [Pred_MCI_2;pred_label_MCI_2];
            Fold_MCI_2{i,2}       = pred_label_MCI_2;
            if Num_task~=5
                Pred_AD_2     = [Pred_AD_2;pred_label_AD_2];
                Fold_AD_2{i,2}        = pred_label_AD_2;
            end
            
            
            
        end
        %% Results
        if Num_task~=5
            act_label_All       = [Act_NC_1;Act_MCI_1;Act_AD_1;Act_NC_2;Act_MCI_2;Act_AD_2];
            pred_label_All      = [Pred_NC_1;Pred_MCI_1;Pred_AD_1;Pred_NC_2;Pred_MCI_2;Pred_AD_2];
            INDX_ALL            = [INDX_NC_1;INDX_MCI_1;INDX_AD_1;INDX_NC_2;INDX_MCI_2;INDX_AD_2];
        else
            act_label_All       = [Act_NC_1;Act_MCI_1;Act_AD_1;Act_NC_2;Act_MCI_2];
            pred_label_All      = [Pred_NC_1;Pred_MCI_1;Pred_AD_1;Pred_NC_2;Pred_MCI_2];
            INDX_ALL            = [INDX_NC_1;INDX_MCI_1;INDX_AD_1;INDX_NC_2;INDX_MCI_2];
        end
        
        cor(h)              = corr(act_label_All,pred_label_All);
        cor_s(h)            = corr(act_label_All,pred_label_All,'type','Spearman');
        MAE(h)              = mean(abs(act_label_All - pred_label_All));
        
        results{h,1}    = act_label_All;
        results{h,2}    = pred_label_All;
        results{h,3}    = INDX_ALL;
        
        CorNC_1(h)            = corr(Act_NC_1,Pred_NC_1);
        MAE_NC_1(h)           = mean(abs(Act_NC_1 - Pred_NC_1));
        results_NC_1{h,1}     = Act_NC_1;
        results_NC_1{h,2}     = Pred_NC_1;
        results_NC_1{h,3}     = INDX_NC_1;
        
        CorNC_2(h)            = corr(Act_NC_2,Pred_NC_2);
        MAE_NC_2(h)           = mean(abs(Act_NC_2 - Pred_NC_2));
        results_NC_2{h,1}     = Act_NC_2;
        results_NC_2{h,2}     = Pred_NC_2;
        results_NC_2{h,3}     = INDX_NC_2;
        
        CorMCI_1(h)            = corr(Act_MCI_1,Pred_MCI_1);
        MAE_MCI_1(h)           = mean(abs(Act_MCI_1-Pred_MCI_1));
        results_MCI_1{h,1}     = Act_MCI_1;
        results_MCI_1{h,2}     = Pred_MCI_1;
        results_MCI_1{h,3}     = INDX_MCI_1;
        
        CorMCI_2(h)            = corr(Act_MCI_2,Pred_MCI_2);
        MAE_MCI_2(h)           = mean(abs(Act_MCI_2-Pred_MCI_2));
        results_MCI_2{h,1}     = Act_MCI_2;
        results_MCI_2{h,2}     = Pred_MCI_2;
        results_MCI_2{h,3}     = INDX_MCI_2;
        
        CorAD_1(h)            =corr(Act_AD_1,Pred_AD_1);
        MAE_AD_1(h)           = mean(abs(Act_AD_1-Pred_AD_1));
        results_AD_1{h,1}     = Act_AD_1;
        results_AD_1{h,2}     = Pred_AD_1;
        results_AD_1{h,3}     = INDX_AD_1;
        
        if Num_task~=5
            CorAD_2(h)            =corr(Act_AD_2,Pred_AD_2);
            MAE_AD_2(h)           = mean(abs(Act_AD_2-Pred_AD_2));
            results_AD_2{h,1}     = Act_AD_2;
            results_AD_2{h,2}     = Pred_AD_2;
            results_AD_2{h,3}     = INDX_AD_2;
        end
                
        Fold_NC_H_1{h,1}      = Fold_NC_1;
        Fold_MCI_H_1{h,1}     = Fold_MCI_1;
        Fold_AD_H_1{h,1}      = Fold_AD_1;
        
        Fold_NC_H_2{h,1}      = Fold_NC_2;
        Fold_MCI_H_2{h,1}     = Fold_MCI_2;
        if Num_task~=5
            Fold_AD_H_2{h,1}      = Fold_AD_2;
        end
        
        
    end
    if Num_task~=5
        save(['Results_',Months{Month},'_Months.mat'],'results','results_NC_1','results_MCI_1','results_AD_1','results_NC_2','results_MCI_2','results_AD_2','cor','MAE','cor_s','CorNC_1','CorMCI_1','CorAD_1','CorNC_2','CorMCI_2','CorAD_2','MAE_NC_1','MAE_MCI_1','MAE_AD_1','MAE_NC_2','MAE_MCI_2','MAE_AD_2','Fold_NC_H_1','Fold_MCI_H_1','Fold_AD_H_1','Fold_NC_H_2','Fold_MCI_H_2','Fold_AD_H_2');
    else
        save(['Results_',Months{Month},'_Months.mat'],'results','results_NC_1','results_MCI_1','results_AD_1','results_NC_2','results_MCI_2','cor','MAE','cor_s','CorNC_1','CorMCI_1','CorAD_1','CorNC_2','CorMCI_2','MAE_NC_1','MAE_MCI_1','MAE_AD_1','MAE_NC_2','MAE_MCI_2','Fold_NC_H_1','Fold_MCI_H_1','Fold_AD_H_1','Fold_NC_H_2','Fold_MCI_H_2');
    end
end
end