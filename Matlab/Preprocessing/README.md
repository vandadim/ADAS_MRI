# IMPLEMENTATIONS
## Note:
Please note to install the correct version of SPM12 and Cat12 before running the functions.

SPM12 version 6906

Cat12 version 1207 

For the preprocessing, the following scripts will need to be available in the Matlab path:

   adas_prepare_data_average_sc.m
   
   catSegment_job.mat
   
   rdir.m
   
   reorient.m
   
   standard_seg.m

## Package Usage:

SPM12

CAT12

The directory containing the mentioned packages can be added to the Matlab path as follows:
```matlab
addpath C:\Users\vandad\spm12
addpath C:\Users\vandad\cat12
```
The standard_seg function is the first main function. It requires three mandatory arguments:

dataPath   : The data path in which subjects are available.

matFilePath: The catSegment_job path 

outPath    : The output path

The adas_prepare_data_average_sc function is the second main function. It requires three mandatory arguments:

```matlab
datadir{1} = '..\ADNI1screening_segmented'; % ADNI 1

datadir{2} = '..\ADNI2screening_segmented'; % ANDI 2

templatefn = '..\aal.nii'; % Template

outpath    = '..\AAL;


dataPath_ADNI1      = '\Path\of\ADNI\data\with\ADNI1';
dataPath_ADNI2      = '\Path\of\ADNI\data\with\ADNI2';
outPath_ADNI1       = '\Path\of\segmented\ADNI1_Imgs';
outPath_ADNI2       = '\Path\of\segmented\ADNI2_Imgs';
matFilePath         = '\Path\of\catSegment_job.mat';

standard_seg(dataPath_ADNI1, matFilePath, outPath_ADNI1);
standard_seg(dataPath_ADNI2, matFilePath, outPath_ADNI2);

datadir{1} = outPath_ADNI1;
datadir{2} = outPath_ADNI2;
templatefn = '\Path\of\Template\aal.nii'; % Template
outpath    = '\Path\of\AVG_AAL';
adas_prepare_data_average_sc(datadir,templatefn,outpath);
```


