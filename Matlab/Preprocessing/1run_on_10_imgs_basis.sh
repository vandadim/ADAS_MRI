#!/usr/bin/sh

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------
#os.system('python generate_mfile_per_image.py')
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------
numImgs=630
for((part=1;part<630;part=part+10))
{
for((m=part;m<part+10;m++))
	{
	matlab -nodesktop -r mfile_"$m" &
	}
	wait
}