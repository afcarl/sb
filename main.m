
% XXXX  TODO ????
% 1. Subtract mean from samples, as preprocessing step.
% 2. Check if glueing would recover results of mutual information
% 3. Optimize pAUC for sb_classifier- grid search over eta and alpha.
% 4. writes tests for mk_bnet functions
% 5. Cache kernel matrices / inspect which part is slow. 
% 6. Increase sample size.
% 7. Check what happens when I combine gaussian kernel with linear (provide
% func to add kernels).
% 8. Get ci and kci linear to give the same results.
% 9. Explore manually which kernels work well. It's enough to have a paper
% on a good kernel.
% 10. Add check in BNT that rows of CPDs sum to 1


% clear all;
global debug
debug = 0;
close all;

bnet = mk_asia_large_arity(5); %mk_bnet4();
K = length(bnet.dag);
arity = get_arity(bnet);

max_S = 2;
triples = gen_triples(K, max_S);

num_experiments = 30;
num_samples = 200;
step_size = 1e-3;
range = 0:step_size:1;
%eta_range = log2(1:0.01:1.2);%log2(1:.001:1.1);
%alpha_range = [0 10.^(-3:0.2:3)];%[0 10.^(-3:0.2:3)];

empty = struct('name', 'none');
L = LinearKernel();
G = GaussKernel();
% C1 = CombKernel({L, G}, {-0.1, 1});
LA = LaplaceKernel();
full_options = {struct('classifier', @kci_classifier, 'kernel', L, 'range', range, 'color', 'g' ,'params',[]), ...
           struct('classifier', @kci_classifier, 'kernel', G, 'range', range, 'color', 'b','params',[] ), ...
           struct('classifier', @kci_classifier, 'kernel', LA, 'range', range, 'color', 'm' ,'params',[]), ...
           struct('classifier', @pc_classifier, 'kernel', empty, 'range', range, 'color', 'r','params',[] ), ...
           struct('classifier', @cc_classifier, 'kernel', empty, 'range', range, 'color', 'k','params',[] ), ...
           struct('classifier', @mi_classifier, 'kernel', empty, 'range', 0:step_size:log2(arity), 'color', 'y','params',[] ), ...
           struct('classifier', @sb_classifier, 'kernel', empty,'range',range, 'color', 'm','params',struct('eta',0.01,'alpha',1))};

options = full_options(1:3);
num_classifiers = length(options);
name = cell(1,num_classifiers);
TPR = cell(1,num_classifiers);
FPR = cell(1,num_classifiers);
w_acc = cell(1,num_classifiers);

% label each CPD as either independent (1) or dependent (0)
indep = zeros(length(triples), 1);
edge = zeros(length(triples),1);
fprintf('Computing ground truth indep.\n');
for t = 1 : length(triples)
    i = triples{t}(1);
    j = triples{t}(2);
    indep(t) = double(dsep(i, j, triples{t}(3:end), bnet.dag));
    edge(t) = (bnet.dag(i,j) || bnet.dag(j,i));
end
% only keep dependent distributions corresponding to an edge (along with
% any conditioning sets)
keep = (indep | edge);
triples = triples(keep);
indep = indep(keep);

num_indep = length(find(indep));
fprintf('Testing %d independent and %d dependent CPDs, arity=%d.\n',num_indep,length(indep)-num_indep,arity);


% allocate
for c = 1:num_classifiers
    o = options{c};
    name{c} = sprintf('%s, kernel = %s', func2str(o.classifier), o.kernel.name);
    name{c} = strrep(name{c}, '_', ' ');
    num_thresholds = length(o.range);
    
    param_size{c} = [];
    if (isstruct(o.params))
        fields = fieldnames(o.params);
        for i = 1:length(fields)
            param_size{c} = [param_size{c} length(o.params.(fields{i}))];
        end
    end
    
    %w_acc{c} = zeros([num_experiments param_size{c}] );
    TPR{c} = zeros([num_experiments num_thresholds param_size{c}]);
    FPR{c} = zeros([num_experiments num_thresholds param_size{c}]);
end

total_time = 0;
for exp = 1:num_experiments
    
    fprintf('Experiment #%d, sampling from bayes net.\n',exp);
    s = samples(bnet, num_samples);
    time_exp = 0;
    for c = 1:num_classifiers
        tic;
        %fprintf('  Testing %s...\n',name{c});
        o = options{c};
        opt = struct('arity', arity, 'kernel', o.kernel,'range', o.range,'params',o.params);
        
        % allocate
        classes = zeros([length(o.range) param_size{c}]);
        num_thresholds = length(o.range);
        scores = zeros([2 2 num_thresholds param_size{c}]);
        
        % apply classifier
        for t = 1 : length(triples)
            emp = s(triples{t}, :);
            
            % evaluate classifier at all thresholds in range
            indep_emp = o.classifier(emp, opt);
            indep_emp = reshape(indep_emp,[1 1 size(indep_emp)]);
            
            % increment scores accordingly (WARNING: HARD-CODED max num
            % params to optimize as 2)
            scores(1 + indep(t),1,:,:,:) = scores(1 + indep(t),1,:,:,:) + ~indep_emp;
            scores(1 + indep(t),2,:,:,:) = scores(1 + indep(t),2,:,:,:) + indep_emp;
        end        

        % evaluate
        for r = 1 : num_thresholds
            P = scores(2, 1, r, :, :) + scores(2, 2, r, :, :);
            N = scores(1, 1, r, :, :) + scores(1, 2, r, :, :);
            TP = scores(2, 2, r, :, :);
            TN = scores(1, 1, r, :, :);
            FP = scores(1, 2, r, :, :);
            TPR{c}(exp, r, :, :) = squeeze(TP ./ P); % = TP ./ (TP + FN)
            FPR{c}(exp, r, :, :) =  squeeze(FP ./ N); % = FP ./ (FP + TN);
        end
        time_classifier = toc;
        time_exp = time_exp + time_classifier;
        fprintf('   Finished %s, time = %d seconds.\n',name{c},time_classifier);
    end
    total_time = total_time + time_exp;
    fprintf('Time for experiment %d is %d\n',exp,time_exp);

end

fprintf('Total running time for all experiments is %d seconds.\n',total_time);

