disp('test_plot_empirical_pvals...')

randn('seed', 1);
rand('seed', 1);

x = randn(500, 1);
y = rand(200, 1);

z = [x; y];
ind = logical([ones(500, 1); zeros(200, 1)]);

[y1, y2, y3, x, a] = plot_empirical_pvals(z, ind, false);



