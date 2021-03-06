disp('test_fit_f..')

% sample from an uneven distribution over {1, 3, 5, 7, 9} 
seed_rand(1);
y = mnrnd(100, [0.1 0.4 0.05 0.3 0.15]);
z = [ones(y(1), 1); 3*ones(y(2), 1); 5*ones(y(3), 1); 7*ones(y(4), 1); 9*ones(y(5), 1)];

[f, x, z, bw, uu] = fit_f(z', false, true);
assert(bw == min(uu));

