% function test_run_gobnilp()

bnet = mk_bnet4_vstruct();
K = size(bnet.dag,1);
S = cell(K,1);
nodes = 1:K;

good = -0.1;
bad = -10000;

N = 1000;
s = samples(bnet,N);
maxpa = min(4,K-1);

for i = 1:K
    others = setdiff(nodes,i);
    parent_sets = combinations(others,maxpa);
    S = {};
    for j = 1:size(parent_sets,1)
        if dsep(i,j,parent_sets(j,:),bnet.dag)
            
        end
            
        S{end+1} = struct('score', ,'parents',parent_sets(j,:));
    end
    
end
% 
% S{1} = {struct('score', indep,'parents', []), ...
%     struct('score', dep ,'parents', [2]), ...
%     struct('score', dep ,'parents', [3]), ...
%     struct('score', dep ,'parents', [2 3])};
% S{2} = {struct('score', indep,'parents', []), ...
%     struct('score', dep ,'parents', [1]), ...
%     struct('score', dep ,'parents', [3]), ...
%     struct('score', dep ,'parents', [1 3])};
% S{3} = {struct('score', indep,'parents', []), ...
%     struct('score', dep ,'parents', [1]), ...
%     struct('score', dep ,'parents', [2]), ...
%     struct('score', dep ,'parents', [1 2])};