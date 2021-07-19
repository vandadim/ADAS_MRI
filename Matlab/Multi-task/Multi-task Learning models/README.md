# Multi-Task learning
In the Multi-task learning we used different multi-task learning methods based on least-squares loss function including multi-task Lasso (Least Lasso), Joint Feature Selection (JFS), Dirty Model (Least Dirty), and Trace-Norm Regularization (Least Trace).

- MTL-fun
    
   - Without Harmonization
   ```matlab
   % OUTPUT          : 
   % Results         : 'results','results_NC','results_MCI','results_AD','cor','MAE','cor_s','CorNC','CorMCI','CorAD','MAE_NC','MAE_MCI','MAE_AD', ...
                        'Fold_NC_H','Fold_MCI_H','Fold_AD_H'
   % INPUT           :
   % Datapath        : The directory containing data
   % Harmonization   : 0- Without data monization, 1- ComBat harmonization, 2- PLS-based domain adaptation  
   % Covariate       : 0- Without considering Age as covariate, 1-With considering Age as covariate
   % Formulations    : 0- Least Lasso, 1-Joint feature selection (JFS), 2- Dirty Model, 3- Low rank assumption (LRA)
   %--------------------------------------------------------------------------------------------------------------------------------------------
   %--------------------------------------------------------------------------------------------------------------------------------------------
   Datapath       = '/path/to/the/data/folder';
   Harmonization  = 0;
   Covariate      = 0;
   Formulations   = 0; % Or 1 Or 2 Or 3
   MTL_fun(Datapath,Harmonization,Covariate,Formulations)
   
   ```
   - ComBat + MTLs
   
     ```matlab
        Datapath       = '/path/to/the/data/folder';
        Harmonization  = 1;
        Covariate      = 0; % Or 1
        Formulations   = 0; % Or 1 Or 2 Or 3
        MTL_fun(Datapath,Harmonization,Covariate,Formulations)
   
      ```                  
   - PLS-Based Domain adaptation + MTLs

     ```matlab     
         Datapath       = '/path/to/the/data/folder';
         Harmonization  = 2;
         Covariate      = 0; % Or 1
         Formulations   = 0; % Or 1 Or 2 Or 3
         MTL_fun(Datapath,Harmonization,Covariate,Formulations)     
     ```
