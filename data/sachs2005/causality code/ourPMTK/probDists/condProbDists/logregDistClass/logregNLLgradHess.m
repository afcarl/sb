function [f,g,H] = logregNLLgradHess(beta, X, y, lambda)
% gradient and hessian of negative log likelihood for logistic regression
%
% Rows of X contain data
% y(i) = 0 or 1
% lambda is optional strength of L2 regularizer


[nexamples,ndimensions] = size(X);
if nargin < 4,lambda = 0; end
check01(y);
mu = 1 ./ (1 + exp(-X*beta)); % mu(i) = prob(y(i)=1|X(i,:))
f = -sum( (y.*log(mu+eps) + (1-y).*log(1-mu+eps))) + lambda/2*sum(beta.^2); 
f = f./nexamples;
g = []; H  = [];
if nargout > 1
  g = X'*(mu-y) + lambda*beta;
  g = g./nexamples;
end

if nargout > 2
  W = diag(mu .* (1-mu)); %  weight matrix
  H = X'*W*X + lambda*eye(length(beta));
  H = H./nexamples;
end
