function  [trained_label,test_label] = svmTrainY (train_labl,train_indx,kf,nuMatFile,XS_all)

balancd_CV2 = balanced_crossval(train_labl,kf,[]);

predY_all= [];
yLabel_all=[];


for k = 1:kf
    
    train2_label = train_labl(balancd_CV2~= k);
    test2_label  = train_labl(balancd_CV2== k);
    train2_indx  = balancd_CV2~= k;
    test2_indx   = balancd_CV2== k;
    predY =[];
    for it= 1:nuMatFile   %122
        
        train_set       = XS_all{it}(train_indx,:);
        trainSet_ncv    = train_set(train2_indx,:);
        testSet_ncv     = train_set(test2_indx,:);
        
        nTrainSet_ncv   = zscore(trainSet_ncv);
        nTestSet_ncv    = zscore(testSet_ncv);
        model           = svmtrain(train2_label,nTrainSet_ncv,'-s 4');
        [pred_label, accuracy, decision_values] = svmpredict(test2_label, nTestSet_ncv,model);
        predY           = [predY pred_label];
        
    end
    predY_all  = [predY_all; predY];
    yLabel_all = [yLabel_all; test2_label];
end
trained_label  = predY_all;
test_label     = yLabel_all;
end