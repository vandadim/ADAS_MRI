# ALL-EN Function
To use ALL_EN function, the following scripts need to be available in the Matlab path:
```matlab
   - rdir.m
   - balanced_crossval.m
```
- ALL-EN
   - Without Harmonization
   ```matlab
   % OUTPUT          : 
   % Results         : 'results','results_NC','results_MCI','results_AD','cor','MAE','cor_s','CorNC','CorMCI','CorAD','MAE_NC','MAE_MCI','MAE_AD'
   % INPUT           :
   % Datapath        : The directory containing data
   % Harmonization   : 0- Without data monization, 1- ComBat harmonization, 2- PLS-based domain adaptation  
   % Covariate       : 0- Without considering Age as covariate, 1-With considering Age as covariate
   %--------------------------------------------------------------------------------------------------------------------------------------------
   %--------------------------------------------------------------------------------------------------------------------------------------------
   Datapath       = '/path/to/the/data/folder';
   Harmonization  = 0;
   Covariate      = 0;
   ALL_EN(Datapath,Harmonization,Covariate)
   
   ```
   - ComBat+ALL-EN
   
     ```matlab
        Datapath       = '/path/to/the/data/folder';
        Harmonization  = 1;
        Covariate      = 0; Or 1
        ALL_EN(Datapath,Harmonization,Covariate)
   
      ```                  
   - PLS-Based Domain adaptation

     ```matlab     
         Datapath       = '/path/to/the/data/folder';
         Harmonization  = 2;
         Covariate      = 0; Or 1
         ALL_EN(Datapath,Harmonization)     
     ```
