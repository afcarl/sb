%% Samples from a GGM
%#testPMTK
d = 10;
G = UndirectedGraph('type', 'loop', 'nnodes', d);
obj = UgmGaussDist(G, [], []);
obj = mkRndParams(obj);
n = 1000;
X = sample(obj, n);
S = cov(X);
L = inv(S);
figure;
subplot(1,2,1); imagesc(G.adjMat); colormap('gray'); title('truth')
subplot(1,2,2); imagesc(L); colormap('gray'); title('empirical prec mat')