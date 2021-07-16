% Generating balanced cross validation folds for regression
% (C) Jussi Tohka 2014 - 2016
% Tampere University of Technology, Finland (2014 - 2015)
% Universidad Carlos III de Madrid, Spain (2015 - 2016)
% --------------------------------------------------------------
% Permission to use, copy, modify, and distribute this software 
% for any purpose and without fee is hereby
% granted, provided that the above copyright notice appear in all
% copies.  The author and Tampere University of Technology and
% Universidad Carlos III de Madrid make no representations
% about the suitability of this software for any purpose.  It is
% provided "as is" without express or implied warranty.
% -------------------------------------------------------------
% OUTPUT : 
% foldid : id's of folds 
% INPUT:
% y   : response variables
% nfolds : number of folds (e.g. 10)
% subjno : Subject number in case of several measurements from the same
%          subject. We want all of these be in the same fold. Give an empty
%          matrix if this is not a concern. 
% complete: usually 1 if subject numbers given and 0 if not
% dont_balance : usually 0 - value 1 produces folds with no balancing 
% -------------------------------------------------------------
% Use 
% foldid = balanced_crossval(y,10,[],0,0);
% for the standard case
% -----------------------------------------------------------


function foldid = balanced_crossval(y,nfolds,subjno,complete,dont_balance);
 
  maxscans = 3;
  iterations = 1;
  if ~exist('complete','var')
    complete = 0;
  end
  if isempty(subjno)
    complete = 0;
  end  
  if ~exist('dont_balance','var')
    dont_balance = 0;
  end
  
  if ~isempty(subjno)
    [btmp,uidx,uidx2] = unique(subjno,'first');
    if complete
      scanidx = zeros(length(btmp),maxscans);
      nscans = zeros(length(btmp),1);
      for i = 1:length(btmp)
        idx = find(subjno == btmp(i));
        nscans(i) = length(idx);
        if nscans(i) > 1
          [~,si] = sort(y(idx));
          idx = idx(si);
        end    
        scanidx(i,1:nscans(i)) = idx; 
      end 
      for i = 1:maxscans
        uidx3{i} = find(nscans == i);
      end  
      iterations = maxscans;
      y1 = y;
      foldid_complete = zeros(size(y));
    else
      y = y(uidx);
    end

  end   
     
  for iter = 1:iterations 
    if iterations > 1
      y = y1(scanidx(uidx3{iter},1));
    end  
    [sy sidx] = sort(y);
    if dont_balance 
        sidx = 1:length(y);
    end
    for i = 1:(floor(length(y)/(2*nfolds)))
      r = randsample(nfolds,nfolds);
      foldid(sidx((i - 1)*nfolds + [1:nfolds])) = r;
    end
    t = (floor(length(y)/(2*nfolds)))*nfolds;
    r = randsample(nfolds,mod(length(y),nfolds));
    foldid(sidx(t + [1:mod(length(y),nfolds)])) = r;
    t = t + mod(length(y),nfolds);
    k = floor(length(y)/(nfolds)) - floor(length(y)/(2*nfolds));
    for i = 1:k
      r = randsample(nfolds,nfolds);
      foldid(sidx(t + (i - 1)*nfolds + [1:nfolds])) = r;
    end
    if (~isempty(subjno)) & (~complete)
      foldid = foldid(uidx2);
    end    
    if complete
     % keyboard
      for j = 1:iter
        foldid_complete(scanidx(uidx3{iter},j)) = foldid;
      end
      clear foldid
    end
    
  end 
  if complete 
    foldid = foldid_complete;
  end
  
  
  % keyboard
  
