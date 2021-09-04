#!/user/bin/python
import os

def generateMfile(crun, dataPath, outPath, matFilePath, nRun, genMfiles):
	# within the generated mFile spatiotemporal_index function is called. 
	mFileName   = 'mfile_' + crun + '.m'
	mFile       = open(mFileName,'w')
	mFile.write("imgs_dir = rdir(['" + dataPath + "' '/*/MPRAGE/**/ADNI*.nii']);\n")
	mFile.write("imgs_dir = imgs_dir(" + crun + ");\n")
	mFile.write("jobfile  = importdata (['" + outPath + "' '" + matFilePath + "']);\n")
	mFile.write("numImg   = length(imgs_dir);\n")
	mFile.write("nRun     = 1;\n")
	mFile.write("jobs     = repmat(jobfile, 1, nRun);\n")
	mFile.write("inputs   = cell(0, nRun);\n")
	mFile.write("%numImgToRun = numImg;\n")	
	mFile.write("jobs{1}.spm(1).tools(1).cat(1).estwrite(1).data = cell(nRun,1);  % data is column cell\n")
	mFile.write("P    = imgs_dir.name;\n")
	mFile.write("newP = reorient(P,'" + outPath + "'," + crun + ");\n")
	mFile.write("jobs{1}.spm(1).tools(1).cat(1).estwrite(1).data{" + nRun + ",1}= newP.fname;\n")
	mFile.write("spm('defaults', 'FMRI');\n")
	mFile.write("spm_jobman('run',jobs,inputs{:});\n")
	mFile.close()


genMfilesDir    = 'genMfiles'

if not os.path.exists(genMfilesDir):
	os.mkdir(genMfilesDir)

numImgs             = 10 # Number of Images you would like to process 
dataPath            = '/home/users/justoh/data/ADNIrawMRI/ADNI2screening/ADNI'
outPath             = '/research/users/marziez/CatSegmentation_auto'
matFilePath         = '/programming/new/catSegment_job.mat'
curr_dir            = os.getcwd()
matlabDir 	        = 'matlab'

for crun in range(1, numImgs+1, 1):
	generateMfile(str(crun), dataPath, outPath, matFilePath, '1', genMfilesDir)

