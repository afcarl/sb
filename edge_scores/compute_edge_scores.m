function [E, info] = compute_edge_scores(emp, opt, maxS, pre)

R = zeros(size(emp, 1));
triples = gen_triples(size(emp, 1), 0:maxS);
info = cell(length(triples), 1);

if ~exist('pre', 'var')
    if isfield(opt, 'prealloc')
        pre = opt.prealloc(emp, opt);
    else
        pre = [];
    end
end

for t = 1:length(triples)
    [R(triples{t}.i,triples{t}.j), info{t}] = classifier_wrapper(emp, ...
        triples{t}, opt.classifier, opt, pre);  
end

if (isfield(opt, 'pval') && opt.pval)
    % fit mixture model over pvals
    zz = norminv(R); 
    z = zz(~isnan(zz) & ~isinf(zz));
    gmix = fitgmdist(z, 2, 'Regularize', 0.01);
    disp(gmix);
    plot_fit(gmix, z);
    
    % convert pvals to p(H1)
    P = posterior(gmix, z);
    [~, idx] = max(gmix.mu);
    
    % place these values in appropriate position in R matrix 
    E = zz;
    E(find(~isnan(zz) & ~isinf(zz))) = -log(P(:, idx));
else
    R = my_sigmoid(R, 0.05, 20);
    E = 1 ./ R; %-log(R); 
end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function plot_fit(gmix, z)
        plot_flag = false;
        if plot_flag
            x = linspace(min(z), max(z));
            y = pdf(gmix, x');
            [y2, x2] = ksdensity(z);
            figure(2);
            clf
            hold on;
            plot(x2, y2, 'k-', 'linewidth', 2);
            plot(x, y, 'b-', 'linewidth', 2);
            legend('KDE', 'Gauss mixture model');
        end
    end

end



