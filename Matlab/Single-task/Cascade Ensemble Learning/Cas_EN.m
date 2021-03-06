% Generating Single-task learning model for regression
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
% Path          : The directory containing data
% Harmonization : 1- ComBat harmonization, 2- PLS-based domain adaptation
% Covariate     : 0- Without considering Age as covariate, 1-With considering Age as covariate

% --------------------------EXAMPLE--------------------------
% Use for predicting without considering harmonization step
% and effect of the biological covariate.
% Datapath       = '/path/to/the/data/folder';
% Harmonization  = 0;
% Covariate      = 0;
% Cas_EN(Datapath,Harmonization,Covariate)
%
% -----------------------------------------------------------
function Cas_EN(Path,Harmonization,Covariate)
if ~exist('Harmonization','var') || Harmonization~=1 || Harmonization~=2
    error('Error. Harmonization must be 1 (ComBat) or 2 (PLS)');
end
if ~exist('Covariate','var')
    Covariate = 0;
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
    %Selceted parameter for GLMNET
    opt             = glmnetSet();
    opt.alpha       = 0.5;
    opt.standardize = 0;
    % Initialize output
    cor             = zeros(10,1);
    MAE             = zeros(10,1);
    results         = cell(10,3);
    results_NC      = cell(10,3);
    results_MCI     = cell(10,3);
    results_AD      = cell(10,3);
    XS_all          = cell(122,1);
    
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
        
        %% ComBat
        if Harmonization==1 && Covariate ==1            
            site_AD             = matRegions.ADNI;
            site_AD(n1==1)      = [];
            site_AD(n2==1)      = [];
            Age_AD              = matRegions.age;
            Age_AD(n1==1)       = [];
            Age_AD(n2==1)       = [];
            Data                = fData';
            Batch               = site_AD';
            MOD                 = Age_AD;
            data_harmonized     = combat(Data, Batch, MOD, 1);
            XS_all{it}          = data_harmonized';           
            
        elseif Harmonization==1 && Covariate ==0
            site_AD             = matRegions.ADNI;
            site_AD(n1==1)      = [];
            site_AD(n2==1)      = [];
            Data                = fData';
            Batch               = site_AD';
            MOD                 = [];
            data_harmonized     = combat(Data, Batch, MOD, 1);
            XS_all{it}          = data_harmonized';
        end
        
        %% PLS-Based domain adaptation
        if Harmonization==2 && Covariate ==1            
            site_AD         = matRegions.ADNI;
            site_AD(n1==1)  = [];
            site_AD(n2==1)   = [];
            site_AD1         = dummyvar(site_AD);
            
            Age_AD          = matRegions.age;
            Age_AD(n1==1)   = [];
            Age_AD(n2==1)   = [];
                       
            Response_Variable   = [site_AD1,Age_AD];            
            [~,~,XS,~] = plsregress(fData,Response_Variable,17); % Number of component(Here= 17) can be find in the inner CV loop
            XS_all{it}    = XS;        
        elseif Harmonization==2 && Covariate ==0
            site_AD         = matRegions.ADNI;
            site_AD(n1==1)  = [];
            site_AD(n2==1)   = [];
                       
            Response_Variable   = site_AD;            
            [~,~,XS,~] = plsregress(fData,Response_Variable,17); % Number of component(Here= 17) can be find in the inner CV loop
            XS_all{it}    = XS;
        end
    end    
    for h =1:10
        h
        balancd_CV1 = balanced_crossval(NoYlabel,kf,[]);
        pred_labeln= [];
        act_labeln=[];
        DX_Label=[];
        INDX = [];
        for i = 1:kf
            i
            train1_indx  = find(balancd_CV1~= i);
            train1_label = NoYlabel(balancd_CV1~= i);
            
            test1_label  = NoYlabel(balancd_CV1== i);
            test1_indx   = find(balancd_CV1== i);
            
            DX_Test      = DXlabel(balancd_CV1== i);
            
            [trained_label,test_label] = svmTrainY (train1_label,train1_indx,kf,nuMatFile,XS_all);
            predY  = [];
            for it = 1:nuMatFile      %122
                
                train_set = XS_all{it}(train1_indx,:);
                te_set    = XS_all{it}(test1_indx,:);
                
                nTrainSet_ncv = zscore(train_set);
                nTestSet_ncv = zscore(te_set);
                model = svmtrain(train1_label,nTrainSet_ncv,'-s 4');
                [predicted_label, accuracy, decision_values] = svmpredict(test1_label, nTestSet_ncv,model);
                predY = [predY predicted_label];
                
            end
            
            train = trained_label;
            test  = predY;
            
            nTrainSet2_ncv = zscore(train);
            nTestSet2_ncv = zscore(test);
            CVerr                         = cvglmnet(nTrainSet2_ncv, test_label,'gaussian',opt,'mae',10,[]);
            pred_label1                   = cvglmnetPredict(CVerr,nTestSet2_ncv, CVerr.lambda_min);
            
            
            act_labeln  = [act_labeln; test1_label];
            DX_Label    = [DX_Label; DX_Test];
            pred_labeln = [pred_labeln;pred_label1];
            INDX        = [INDX;test1_indx'];
            
        end
        act_label       = act_labeln;%Normalize_Fcn2(act_labeln,Meanylabel,Stdylabel);
        pred_label      = pred_labeln;%Normalize_Fcn2(pred_labeln,Meanylabel,Stdylabel)
        
        [K1,~]             = ind2sub(size(DX_Label),DX_Label==1);
        [K2,~]             = ind2sub(size(DX_Label),DX_Label==2);
        [K3,~]             = ind2sub(size(DX_Label),DX_Label==3);
        A                   = act_label;
        B                   = pred_label;
        A1                  = A(K1==1);
        B1                  = B(K1==1);
        CorNC(h)            = corr(A1,B1);
        MAE_NC(h)           = mean(abs(A1-B1));
        INDX_NC             = INDX(K1==1);
        results_NC{h,1}     = A1;
        results_NC{h,2}     = B1;
        results_NC{h,3}     = INDX_NC;
        
        A2                  = A(K2==1);
        B2                  = B(K2==1);
        INDX_MCI            = INDX(K2==1);
        CorMCI(h)           = corr(A2,B2);
        MAE_MCI(h)           = mean(abs(A2-B2));
        results_MCI{h,1}     = A2;
        results_MCI{h,2}     = B2;
        results_MCI{h,3}     = INDX_MCI;
        
        A3                  = A(K3==1);
        B3                  = B(K3==1);
        INDX_AD            = INDX(K3==1);
        CorAD(h)            = corr(A3,B3);
        MAE_AD(h)           = mean(abs(A3-B3));
        results_AD{h,1}     = A3;
        results_AD{h,2}     = B3;
        results_AD{h,3}     = INDX_AD;
        
        cor(h)          = corr(act_label,pred_label);
        cor_s(h)        = corr(act_label,pred_label,'type','Spearman');
        MAE(h)          = mean(abs(act_label-pred_label));
        
        results{h,1}    = act_label;
        results{h,2}    = pred_label;
        results{h,3}    = INDX;
    end
    save(['Results_',Months{Month},'_Months.mat'],'results','results_NC','results_MCI','results_AD','cor','MAE','cor_s','CorNC','CorMCI','CorAD','MAE_NC','MAE_MCI','MAE_AD');
end
end
