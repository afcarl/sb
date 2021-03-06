disp('test_normalize_data...')

opt = struct('variance', 10, 'network', 'asia', 'arity', 1, 'data_gen', 'linear_ggm','moralize', false);

bnet = make_bnet(opt);
seed_rand(1);
s = samples(bnet,500);

s = normalize_data(s);
assert(norm(mean(s,2)) < 1e-13);
assert(norm(std(s,[],2) - ones(size(s,1),1)) < 1e-13)

s2 = normalize_data(s, false);
assert(norm(s2-s) < 1e-4);


