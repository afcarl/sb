function beta = elasticNet(X, y, lambda1, lambda2, lassoSolver, varargin)
% elastic net is L1 + L2 regularized least squares regression
% We assume w = lassoSolver(X, y, lambda1, varargin{:})
% We assume X is standardized and y is centered
% See elasticNetPath for general data

if nargin < 5
  lassoSolver = @LassoShooting;
end
[n d] = size(X);
S = sqrt(1+lambda2);
Xstar = 1/S*[X; sqrt(lambda2)*eye(d,d)];
ystar = [y; zeros(d,1)];
gamma = lambda1/S;
betaStar = lassoSolver(Xstar, ystar, gamma, varargin{:});
%beta = betaStar/S; % naive enet
beta = S*betaStar; % corrected enet
