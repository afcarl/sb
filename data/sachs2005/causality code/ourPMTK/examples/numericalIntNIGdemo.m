%% Demo of computing posterior moments of NIG using numerical integration
%#testPMTK
function demoNumericalIntNIG()

setSeed(1);
muTrue = 5; varTrue = 10;
X = sample(GaussDist(muTrue, varTrue), 5);
m0 = 0; k0 = 0.001; a0 = 0.001; b0 = 0.001;
prior = NormInvGammaDist('mu', m0, 'k', k0, 'a', a0, 'b', b0);
m = fit(Gauss_NormInvGammaDist(prior), 'data', X);
post = m.muSigmaDist; % NIG
logZ = lognormconst(post)
Zexact = exp(logZ)
%Zapprox = dblquad(@postJoint, -inf, inf, 0, inf)
Zapprox = dblquad(@postJoint, -1e5, 1e5, 1e-5, 1e5)


% nested function
function post = postJoint(m,s2)
% post = p(m,s2, X)
 n = length(m); s2 = s2*ones(n,1);
 loglik = sum(logprob(GaussDist(m,s2),X));
 logprior = logprob(prior, [m(:) s2(:)]);
 logpost = loglik(:) + logprior(:);
 post = exp(logpost);
end

end