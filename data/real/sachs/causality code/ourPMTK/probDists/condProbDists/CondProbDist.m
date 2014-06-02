classdef CondProbDist < ParamDist
  % conditional probability density function (y|x)
  
  properties
    ndimsX;
    ndimsY = 1;
  end

  %%  Main methods
  methods
     
      function d = ndimensions(obj)
         d = obj.ndimsX; 
      end
      
       function p = logprob(model, X, y)
          % p(i) = log p(y(i) | X(i,:), model params)
          py = predict(model, X);
          p = logprob(py, y(:)'); % L(1,j) = log p(y(j) | params(j))
          %%[yhat] = mean(predict(model, X));
          %s2 = model.sigma2;
          %p = -1/(2*s2)*(y(:)-yhat(:)).^2 - 0.5*log(2*pi*s2);
        end
        
        function p = squaredErr(model, X, y)
          % p(i) = (y(i) - yhat(i))^2
          yhat = mean(predict(model, X));
          p  = (y(:)-yhat(:)).^2;
        end

        
        function [mu, stdErr] = cvScore(obj, X, Y, varargin)
            % X(i,:), Y(i,:)
            [nfolds, objective, randOrder] = process_options(...
                varargin, 'nfolds', 5, 'objective', 'logprob','randOrder', true);
            [n d] = size(X);
            [trainfolds, testfolds] = Kfold(n, nfolds, randOrder);
            score = zeros(1,n);
            for k = 1:length(trainfolds)
                trainidx = trainfolds{k}; testidx = testfolds{k};
                Xtest = X(testidx,:);  Xtrain = X(trainidx, :);
                Ytest = Y(testidx,:);  Ytrain = Y(trainidx, :);
                obj = fit(obj, 'X', Xtrain, 'y', Ytrain);
                switch lower(objective)
                    case 'logprob'
                        score(testidx) = logprob(obj,  Xtest, Ytest);
                    case 'squarederr'
                        score(testidx) = squaredErr(obj,  Xtest, Ytest);
                    otherwise
                        error('%s is an unrecognized objective ',objective);
                end
                %fprintf('fold %d, logprob %5.3f\n', k, L(k));
            end
            if 0
                obj = fit(obj, 'X', X, 'y', Y);
                scoreAll = squaredErr(obj,  X, Y);
                figure;
                plot(score); hold on;
                h= line([1 n], [scoreAll scoreAll]); set(h,'color','r');
            end
            mu = mean(score);
            stdErr = std(score, 0, 2)/sqrt(n);
        end
        

    
  end

end