function [sigma_D, K_D]=transformSample(G, sigma_B, delta, B, D)
% Given SigmaB ~ HIW(G, delta, B), compute Sigma_D ~ HIW(G, delta, D) and
% K_D = inv(Sigma_D)

% Kevin Murphy, UBC June 2008
% Based on code by Helen Armstrong, UNSW 2005

perfect_order = G.perfectElimOrder;
rev_perf = perfect_order(end:-1:1);
g = G.adjMat;
p = size(g,1);
g_rev_perf = g(rev_perf,rev_perf);
B_rev_perf=B(rev_perf,rev_perf);
D_rev_perf=D(rev_perf,rev_perf);
sigma_B_rev_perf=sigma_B(rev_perf,rev_perf);
K_B=inv(sigma_B_rev_perf);

cliques = G.cliques;
seps = G.seps;
residuals = G.resids;
num_cliques = length(cliques);
for j=1:num_cliques
  num_Cj(j) = length(cliques{j});
  num_Rj(j) = length(residuals{j});
  num_Sj(j) = length(seps{j});
end

choleskyK_B=chol(K_B);
c1=num_Cj(1,1);
clear index_start index_finish
index_start=p-c1+1; index_finish=p;
indexC_in_Upsilon_D=zeros(1,c1);
indexC1_in_Upsilon_D=[index_start: index_finish];
% this is the last c1 columns
Upsilon_D=zeros(p);
B_1=zeros(c1); D_1=zeros(c1);
Q_1=zeros(c1); P_1=zeros(c1); O_1=zeros(c1);
B_1=B_rev_perf(indexC1_in_Upsilon_D,indexC1_in_Upsilon_D);
Q_1=chol(inv(B_1));
D_1=D_rev_perf(indexC1_in_Upsilon_D,indexC1_in_Upsilon_D);
P_1=chol(inv(D_1));
O_1=inv(Q_1)*P_1; % this is a letter O
Upsilon_D(indexC1_in_Upsilon_D, indexC1_in_Upsilon_D)=...
    choleskyK_B(indexC1_in_Upsilon_D,indexC1_in_Upsilon_D)*O_1;
for j=2:num_cliques
    clear cj indexCj_in_Upsilon_D
    cj=num_Cj(j);
    indexCj_in_Upsilon_D=zeros(1, cj);
    clear Rj rj indexRj_inOj indexRj_in_Upsilon_D
    clear unsort_indexRj_in_Upsilon_D
    Rj=residuals{j};
    rj=num_Rj(j);
    indexRj_inOj=zeros(1,rj);
    indexRj_in_Upsilon_D=zeros(1,rj);
    unsort_indexRj_in_Upsilon_D=zeros(1,rj);
    
    clear Sj sj indexSj_inOj indexSj_in_Upsilon_D
    clear unsort_indexSj_in_Upsilon_D
    Sj=seps{j};
    sj=num_Sj(j);
    indexSj_inOj=zeros(1,sj);
    indexSj_in_Upsilon_D=zeros(1,sj);
    unsort_indexSj_in_Upsilon_D=zeros(1,sj);
    
    B_j=zeros(cj); D_j=zeros(cj);
    Q_j=zeros(cj); P_j=zeros(cj); O_j=zeros(cj); % this is a letter O
    
    for k=1:rj
        unsort_indexRj_in_Upsilon_D(k)=find(rev_perf==Rj(k));
    end
    indexRj_in_Upsilon_D=sort(unsort_indexRj_in_Upsilon_D);
    for k=1:sj
        unsort_indexSj_in_Upsilon_D(k)=find(rev_perf==Sj(k));
    end
    indexSj_in_Upsilon_D=sort(unsort_indexSj_in_Upsilon_D);
    indexCj_in_Upsilon_D=[indexRj_in_Upsilon_D, indexSj_in_Upsilon_D];
    
    B_j=B_rev_perf(indexCj_in_Upsilon_D,indexCj_in_Upsilon_D);
    Q_j=chol(inv(B_j));
    D_j=D_rev_perf(indexCj_in_Upsilon_D,indexCj_in_Upsilon_D);
    P_j=chol(inv(D_j));
    O_j=inv(Q_j)*P_j;
    
    indexRj_inOj=1:rj;
    indexSj_inOj=rj+1:cj;
    
    Upsilon_D(indexRj_in_Upsilon_D, indexRj_in_Upsilon_D)=...
        choleskyK_B(indexRj_in_Upsilon_D, indexRj_in_Upsilon_D)*...
        O_j(indexRj_inOj, indexRj_inOj);
    Upsilon_D(indexRj_in_Upsilon_D,indexSj_in_Upsilon_D)=...
        choleskyK_B(indexRj_in_Upsilon_D,indexRj_in_Upsilon_D)*...
        O_j(indexRj_inOj,indexSj_inOj)+...
        choleskyK_B(indexRj_in_Upsilon_D,indexSj_in_Upsilon_D)*...
        O_j(indexSj_inOj,indexSj_inOj);
end

K_D_rev_perf=zeros(p); sigma_D_rev_perf=zeros(p);
K_D_rev_perf=Upsilon_D'*Upsilon_D; % ~HW(g_rev_perf, delta, D_rev_perf)
sigma_D_rev_perf=inv(K_D_rev_perf); % ~HIW(g_rev_perf, delta, D_rev_perf)
% Note that this is covariance of g wrt the rev_perf ordering, NOT wrt g.
%%% Now need to do inverse permutation to get back to the Sigma for g
inverse_permute=zeros(1,p);
for j=1:p
    inverse_permute(j)=find(rev_perf==j);
end
K_D=zeros(p);
sigma_D=zeros(p);
K_D=K_D_rev_perf(inverse_permute, inverse_permute); % ~Wishart(g, delta+p-1, D) (E(K_D) prop inv(D))
sigma_D=sigma_D_rev_perf(inverse_permute, inverse_permute); % ~HIW(g, delta, D) (E(D) prop D
end