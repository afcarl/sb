%% Soft Conditioning Demo
%#testPMTK
setSeed(0);
muTrue = [0.5 0.5]'; Ctrue = 0.1*[2 1; 1 1];
mtrue = MvnDist(muTrue, Ctrue);
n = 10;
X = sample(mtrue, n);
prior = MvnDist([0 0]', 0.1*eye(2));
A = repmat(eye(2), n, 1);
py = MvnDist(zeros(2*n,1), kron(eye(n), Ctrue));
data = X'; y = data(:);
postMu = softCondition(prior, py, A, y);
m = Mvn_MvnDist(prior, Ctrue);
m = fit(m, 'data', X(1:n,:));
assert(approxeq(postMu.mu, m.muDist.mu))
assert(approxeq(postMu.Sigma, m.muDist.Sigma))