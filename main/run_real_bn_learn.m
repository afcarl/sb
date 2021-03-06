%clear all;
global debug
debug = 2;

%% data
in.data = 'wine';

%% run parameters
in.nvec = 100*(1:6);
in.folds = 10;
in.plot_flag = false;
in.save_flag = true;
in.f_sel = (1:3);       % 1=MMHC, 2=KSB 3=BIC
in.parallel = true;

%% score parameters
in.maxpa = 2;           % max number of parents to allow in learned network
in.max_condset = 2;     % max conditioning set size
in.prune_max = 10;      % number of scores to keep in pruning
in.psi = 1;             % coefficient for edge scores
in.nfunc = @my_one;     % divide by one

%% go
if in.maxpa > 2
    fprintf(['warning- sb3 limited to two parents, while BIC and MMHC' ...
        'can have more than 2\n']);
end
seed_rand(1);
out = bn_learn_real(in);
