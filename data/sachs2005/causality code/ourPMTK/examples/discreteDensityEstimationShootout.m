%% Compare various density estimators on various categorical data sets
%#broken
datasets = {'sachsDiscretized', 'newsgroupsUnique'};
models = {DiscreteDist(), ...
          DiscreteMixDist('nmixtures', 1, 'nrestarts', 1, 'verbose', false),...
          DiscreteMixDist('nmixtures', 2, 'nrestarts', 1, 'verbose', false), ...
          DgmTreeTabular()};
modelNames = {'factored', 'mix1', 'mix2', 'tree'};
  
% factored and mix1 are the same model, since there is just 1 mixture component.
% We include this to check correctness. Note that mix1 is fit with EM
% which is slower. 

for d=1:length(datasets)
  load(datasets{d}); % X is an n x d matrix of discrete data

  Nfolds = 2;
  N = size(X,1);
  setSeed(1);
  randomizeOrder = true;
  [trainfolds, testfolds] = Kfold(N, Nfolds, randomizeOrder);

  for m=1:length(models)
    tic;
    for f=1:Nfolds
      Xtrain = X(trainfolds{f},:);
      Xtest = X(testfolds{f},:);
      M = fit(models{m}, 'data', Xtrain);
      ll = logprob(M, Xtest);
      NLL(f,m) = -sum(ll); %#ok
      tim(f,m) = toc;
    end
  end
  figure; boxplot(NLL, 'labels', modelNames);
  title(sprintf('NLL on %s', datasets{d}));
  drawnow
  
  figure; boxplot(tim, 'labels', modelNames);
  title(sprintf('time on %s', datasets{d}));
  drawnow
end


