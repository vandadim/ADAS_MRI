# Cascade Ensemble Learning

We used Elastic-net penalized linear regression along with SVR (EN+SVR) in the learning stage. Where in the first stage, a PLS-based domain adaptation is performed for each    brain region separately ,and then, for each brain region, the prediction task is performed. These predictions are then combined in the stacking framework. We applied AAL-        atlas to decompose the gray matter density values into 122 distinct regions. For the prediction of the change of ADAS for each brain region, we utilized support vector regression (with a radial basis function kernel). Finally, the per-region predictions were combined using the elastic-net penalized linear regression.

```matlab
   % OUTPUT           
   % Results         : 'results','results_NC','results_MCI','results_AD','cor','MAE','cor_s','CorNC','CorMCI','CorAD','MAE_NC','MAE_MCI','MAE_AD'
   % INPUT           
   % Datapath        : The directory containing data
   % Harmonization   : 1- ComBat harmonization, 2- PLS-based domain adaptation  
   % Covariate       : 0- Without considering Age as covariate, 1-With considering Age as covariate
```
   - [ComBat+Cas-EN](Matlab/Single-task/Cascade%20Ensemble%20Learning/)
   
        ```matlab
            Datapath       = '/path/to/the/data/folder';
            Harmonization  = 1;
            Covariate      = 0; Or 1
            Cas_EN(Datapath,Harmonization,Covariate)
   
        ```                  
   - [PLS-Based Domain adaptation](Matlab/Single-task/Cascade%20Ensemble%20Learning/)

        ```matlab     
            Datapath       = '/path/to/the/data/folder';
            Harmonization  = 2;
            Covariate      = 0; Or 1
            Cas_EN(Datapath,Harmonization,Covariate)     
        ```    
