%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Marzieh 2017
% Edited by Jussi Tohka 2020

% These run on CAT12.

% Matlab version 8.3
% SPM12 version 6906
% Cat12 version 1207 
% addpath ..\spm12
% addpath ..\cat12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% datadir{1} = '..\ADNI1screening_segmented'; % ADNI 1
% datadir{2} = '..\ADNI2screening_segmented_630Imgs'; % ANDI 2
% templatefn = '..\aal.nii'; % Template
% outpath    = '..\AAL;
function adas_prepare_data_average_sc(datadir,templatefn,outpath)
% MRIcrons AAL template
templateV = spm_vol(templatefn);
templateImg = spm_read_vols(templateV);
maxRegionIndex = max(max(templateImg(:)));
for k = 1:maxRegionIndex
    idx{k} = find(templateImg(:) == k);
end
for i = 1:2
    d = dir(datadir{i});
    l(i) = length(d);
end
aalX = zeros(l(1) + l(2) - 4,maxRegionIndex,'single');
tic
RID = zeros(l(1) + l(2) - 4,1);
ADNI = zeros(l(1) + l(2) - 4,1);
s_index = 0;
for i = 1:2
    d = dir(datadir{i});
    for j = 1:length(d)
        if strncmp(d(j).name,'ADNI',4)
            
            dd = dir(fullfile(datadir{i},d(j).name,'mri','mwp1r*'));
            if length(dd) == 1
                s_index = s_index + 1;
                if rem(s_index,10) == 0
                    disp(s_index)
                end
                V = spm_vol(fullfile(datadir{i},d(j).name,'mri',dd(1).name));
                img = spm_read_vols(V);
                for k = 1:maxRegionIndex
                    aalX(s_index,k) = mean(img(idx{k}));
                end
                ADNI(s_index) = i;
                % extract the RID
                RID(s_index) = str2num(dd(1).name(17:20));
            end
        end
    end
end
RID = RID(1:s_index);
ADNI = ADNI(1:s_index);
aalX = aalX(1:s_index,:);
[RID, uidxRID] = unique(nonzeros(RID));
ADNI = ADNI(uidxRID);
aalX = aalX(uidxRID,:);
save(strcat(outpath),'aalX','RID','ADNI');
toc







