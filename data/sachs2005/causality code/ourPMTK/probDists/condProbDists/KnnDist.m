classdef KnnDist < CondProbDist
% A probabilistic K-nearest neighbour classifier - probabilistic in the sense
% that we return a distribution over class labels. 



    properties
        K;              % the number of neighbours to consider
        examples;       % a set of example points nexamples-by-ndimensions
        labels;         % labels corresponding to the above examples
        transformer;    % a data transformer object, e.g. PcaTransformer
        localKernel;    % e.g. Gaussian Kernel - a string or custom function handle
        distanceFcn;    % the global metric, e.g. Euclidean distance: either the string 'sqdist' or a function handle
        useSoftMax      % if true, counts are smoothed using the softmax function, with specified inv temp beta
        beta;           % inverse temperate used in softmax smoothing S(y,beta) = normalize(exp(beta*y)
        verbose;        % if true, (default) display progress in calls to predict
        classPrior;     % A DirichletDist
    end
    
    
    properties(SetAccess = 'protected')
        examplesSOS;    % sum(examples.^2,2)         (set automatically)
        nclasses;       % the number of classes      (set automatically)
        support;        % the support of the labels  (set automatically)
    end
    
    
    methods
       
        function obj = KnnDist(varargin)
            [obj.K,obj.transformer,obj.localKernel,obj.distanceFcn,obj.useSoftMax,obj.beta,obj.classPrior,obj.verbose] =...
                process_options(varargin,...
                'K'             , 1              ,...
                'transformer'   , []             ,...
                'localKernel'   , []             ,...
                'distanceFcn'   , 'sqdist'       ,...
                'useSoftMax'    , true           ,...
                'beta'          , 1              ,...
                'classPrior'    , 'none'         ,...
                'verbose'       , true           );
            
                if ischar(obj.localKernel)
                   obj = setLocalKernel(obj,obj.localKernel);
                end
        end
        
        function obj = fit(obj,examples,labels)
           if(~isempty(obj.transformer))
               [examples,obj.transformer] = train(obj.transformer,examples);
           end
           obj.examples = examples;
           [obj.labels,obj.support] = canonizeLabels(labels);
           obj.nclasses = numel(obj.support);
          
        end
        
        function pred = predict(obj,data)
            if(~isempty(obj.transformer))
                data = test(obj.transformer,data);
            end
            ntest = size(data,1);
            probs = zeros(ntest,obj.nclasses);
            batch = largestBatch(obj,1,ntest);
            if(obj.verbose)
                if(batch(end) == ntest)
                    wbar = waitbar(0,sprintf('Classifying all %d examples in a single batch...',ntest));
                else
                    wbar = waitbar(0,sprintf('Classifying first %d of %d',batch(end),ntest));
                end
                tic;
            end
            while ~isempty(batch)
                probs(batch,:) = predictHelper(obj,data(batch,:));
                if(obj.verbose),t = toc; waitbar(batch(end)/ntest,wbar,sprintf('%d of %d Classified\nElapsed Time: %.2f seconds',batch(end),ntest,t));end
                batch = largestBatch(obj,batch(end)+1,ntest);
            end
            if(obj.verbose && ishandle(wbar)),close(wbar);end
            SS.counts = probs';
            pred = fit(DiscreteDist('-support',obj.support,'-prior',obj.classPrior),'-suffStat',SS);
        end
        
    end
    
    methods(Access = 'protected')
        
        
        function probs = predictHelper(obj,data)
            if isequal(obj.distanceFcn,'sqdist')
                dst = sqDistance(data,obj.examples,sum(data.^2,2),obj.examplesSOS);
            else
                dst = obj.distanceFcn(data,obj.examples);
            end
            [sortedDst,kNearest] = minK(dst,obj.K);
            if ~isempty(obj.localKernel)
                weights = obj.localKernel(data,obj.examples,sortedDst,kNearest);
                counts = zeros(size(data,1),obj.nclasses);
                for j=1:obj.nclasses
                    counts(:,j) = counts(:,j) + sum((obj.labels(kNearest) == j).*weights,2);
                end
            else
                counts = histc(obj.labels(kNearest),1:obj.nclasses,2);
            end
            if(obj.useSoftMax)
                probs = normalize(exp(counts*obj.beta),2);
            else
                probs = normalize(counts,2);
            end 
        end
        
        function batch = largestBatch(obj,start,ntest)
           
            if start > ntest
                batch = []; return;
            end
            prop = 0.10; % proportion of largest possible array size to use
            if(ispc)
                batchSize = ceil( (prop*subd(memory,'MaxPossibleArrayBytes')/8) /size(obj.examples,1));
                batch = start:min(start+batchSize-1,ntest);
            else
                maxsize = 6e6;
                batchSize = ceil(maxsize/size(obj.examples,1));
                batch = start:min(start+batchSize-1,ntest);
            end
        end
        
        function obj = setLocalKernel(obj,kernelName)
            
           switch lower(kernelName)
              
               case 'epanechnikov'
                    obj.localKernel = @epanechnikovKernel;
               case 'tricube'
                    obj.localKernel = @tricubeKernel;
               case 'gaussian'
                    obj.localKernel = @gaussianKernel;
                    
               otherwise
                   error('The %s local kernel has not been implemented, please pass in your own function instead',kernelName);
               
                   
           end
            function weights = gaussianKernel(testData,examples,sqdist,knearest)
                bandwidth = repmatC(sqrt(max(sqdist,[],2))+eps,1,size(knearest,2));
                weights = normalize(eps + (1./((2*pi)*bandwidth)).*exp(-(sqdist./(2*bandwidth.^2))),2);
            end
            
            function weights = tricubeKernel(testData,examples,sqdist,knearest)
                bandwidth = repmatC(sqrt(max(sqdist,[],2))+eps,1,size(knearest,2));
                weights = sqrt(sqdist)./bandwidth;
                in = abs(weights) <= 1;
                weights(in)  = (1-weights(in).^3).^3;
                weights(not(in)) = 0;
                weights = normalize(eps + weights,2);
            end
            
            function weights = epanechnikovKernel(testData,examples,sqdist,knearest)
                bandwidth = repmatC(sqrt(max(sqdist,[],2))+eps,1,size(knearest,2));
                weights = sqrt(sqdist)./bandwidth;
                in = abs(weights) <= 1;
                weights(in)  = (3/4)*(1-weights(in).^2);
                weights(not(in)) = 0;
                weights = normalize(eps + weights,2);
            end
                   
                   
           
            
            
        end
        
        
    end
    
   
    
    methods
        
        function obj = set.examples(obj,examples)
           obj.examples = examples;
           obj.examplesSOS = sum(examples.^2,2);
        end
        
    end
    
    
    
    
end