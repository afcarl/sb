% Illustrate the robustness of the t-distribution compared to the Gaussian.
% Written by Matthew Dunham
function gaussVsT

close all;

n = 30;
seed = 8; randn('state',seed);
data = randn(n,1);
outliers = [8 ; 8.75 ; 9.5];
nn = length(outliers);
nbins = 7;


plotHist(data,nbins,n);
plotPDFs(data,0);
figure;
plotHist(data,nbins,n+nn);
plotHist(outliers,nn,n+nn);
plotPDFs([data ; outliers],0);

%%
% Bucket the data into nbins, divide the size of each bin by norm and plot
% the normalized histogram. 
function plotHist(data,nbins,norm)
    hold on;
    [counts, locations] = hist(data,nbins);
    sCounts = counts ./ norm;
    bar(locations,sCounts);
end
%%
% Fit and plot normal and t distributions. t-distribution MLEs on Gaussian
% generated data might not converge since the optimal value for the degrees
% of freedom -> infinity, (i.e. a Gaussian). In such cases, set useNormMLE
% to 1 to use a sufficiently large value for the dof to approximate a
% Gaussian. 
function plotPDFs(data,useNormMLE)
    Xbar = mean(data);
    sigma = std(data);
    gauss = @(X)normpdf(X,Xbar,sigma);
    if(useNormMLE)
        sT = @(X) studentT(X,Xbar,sigma,100); 
    else
        MLEs = mle(data,'distribution','tlocationscale');
        sT = @(X)studentT(X,MLEs(1),MLEs(2),MLEs(3));
    end
    hold on;
    x = (-5:0.01:10)';
    h(1) = plot(x,gauss(x),'g:','LineWidth',2);
    h(2) = plot(x,sT(x),'r-','LineWidth',2);
    axis([-5,10,0,0.5]);
    set(gca,'YTick',0:0.1:0.5);
    legend(h, 'gaussian', 'student T')
end
%%
% Student's T Distribution
function p = studentT(X,mu,sigma,dof)
    p = (1/sigma)*tpdf( (X-mu) ./ sigma, dof); 
end
%%

end
