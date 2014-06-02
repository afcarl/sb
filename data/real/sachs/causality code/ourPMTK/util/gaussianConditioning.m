
function [muHgivenV, SigmaHgivenV] = gaussianConditioning(mu, Sigma, v, visValues)
% p(xh|xv=visValues) 
d = length(mu);
h = setdiff(1:d, v);  
if isempty(h)
  % instantiated down to a constant scalar
  muHgivenV = []; SigmaHgivenV  = [];
elseif isempty(v)
  % no-op
  muHgivenV = mu; SigmaHgivenV = Sigma;
else
  Shh = Sigma(h,h); Shv = Sigma(h,v); Svv = Sigma(v,v);
  Svvinv = inv(Svv);
  muHgivenV = mu(h) + Shv*Svvinv*(visValues(:)-mu(v));
  SigmaHgivenV = Shh - Shv*Svvinv*Shv';
end
end