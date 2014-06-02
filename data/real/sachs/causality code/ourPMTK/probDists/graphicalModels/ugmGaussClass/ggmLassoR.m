function [precMat, covMat] = ggmLassoR(C, rho, varargin)
% Use R code to find L1-penalized precision matrix

% For instructions on calling R from Matlab, see
% http://www.cs.ubc.ca/~mdunham/tutorial/external.html#21

%#author Rob Tibshirani 
%#url  http://www-stat.stanford.edu/~tibs/glasso/
%#modified Kevin Murphy

[useMBapprox, junk] = process_options(varargin, 'useMB', 0);
%C = cov(X);


  %Calling glasso from R:
  %library("glasso")
%%  x <- matrix(rnorm(50*20),ncol=20)
 % x <- matrix(1:12,ncol=3)
 % s <- var(x)
 % a <- glasso(s, rho=0.1)
 % sol <- a$wi % precision


openR;
evalR('C<-1') % must pre-declare variable before writing a matrix
evalR('L<-1') 
evalR('stuff<-1') 
putRdata('C',C);
putRdata('rho',rho);
putRdata('useMBapprox', useMBapprox)
evalR('stuff <- glasso(C,rho=rho,approx=useMBapprox)'); 
evalR('L <- stuff$wi') % inverse covariance matrix
precMat = getRdata('L');
evalR('L <- stuff$w') %  covariance matrix
covMat = getRdata('L');
closeR;
