%% Linear Regression with a Polynomial Basis Expansion and Error Bars
function hh=linregPolyFitErrorBars(varargin)
    [prior] = process_options(varargin, 'prior', 'mvnIG');
    [xtrain, ytrain, xtest, ytestNoisefree, ytestNoisy, sigma2] = polyDataMake(...
        'sampling', 'thibaux');
    degs = 1:2;
    for i=1:length(degs)
        deg = degs(i);
        T =  ChainTransformer({RescaleTransformer, PolyBasisTransformer(deg)});
        m = Linreg_MvnInvGammaDist('transformer', T, 'priorStrength', 1e-3);
        m = fit(m, 'X', xtrain, 'y', ytrain);
        ypredTest = predict(m, xtest);
        figure;
        hold on;
        h = plot(xtest, mean(ypredTest),  'k-', 'linewidth', 3);
        %scatter(xtrain,ytrain,'r','filled');
        h = plot(xtrain,ytrain,'ro','markersize',14,'linewidth',3);
        NN = length(xtest);
        ndx = 1:20:NN;
        sigma = sqrt(var(ypredTest));
        mu = mean(ypredTest);
        [lo,hi] = credibleInterval(ypredTest);
        if strcmp(prior, 'mvn')
            % predictive distribution is a Gaussian
            assert(approxeq(2*1.96*sigma, hi-lo))
        end
        hh=errorbar(xtest(ndx), mu(ndx), mu(ndx)-lo(ndx), hi(ndx)-mu(ndx));
        %set(gca,'ylim',[-10 15]);
        set(gca,'xlim',[-1 21]);
    end
end