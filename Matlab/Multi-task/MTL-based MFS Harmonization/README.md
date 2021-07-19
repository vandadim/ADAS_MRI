# MTL-based MFS Harmonization

    To correct for differences in features caused by imaging at two MFSs in ADNI1 and ADNI2, we used MTL models as 6-task learning approaches for MFS adaptation.
    ```matlab
       % OUTPUT          : 
       % Results         : 'results','results_NC','results_MCI','results_AD','cor','MAE','cor_s','CorNC','CorMCI','CorAD','MAE_NC','MAE_MCI','MAE_AD'
       % INPUT           :
       % Datapath        : The directory containing data
       % Formulations    : 0- Least Lasso, 1-Joint feature selection (JFS), 2- Dirty Model, 3- Low rank assumption (LRA)
       %--------------------------------------------------------------------------------------------------------------------------------------------
       %--------------------------------------------------------------------------------------------------------------------------------------------
       Datapath       = '/path/to/the/data/folder';
       Formulations   = 0; % Or 1 Or 2 Or 3
       MTL_6tasks(Datapath,Formulations)
           
    ```
