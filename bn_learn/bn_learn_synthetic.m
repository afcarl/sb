function out = bn_learn_synthetic(in)

[rp, learn_opt, bn_opt, SHD, S, T] = init(in);
loop = flatten_loop(rp.num_bnet, rp.num_nrep);
[bnet, bn] = generate_bnets(bn_opt, loop, rp.num_bnet, rp.data_gen);
[s, ti] = deal(zeros(length(loop), 1));

for t = 1:length(learn_opt)
    opt = learn_opt{t};
    disp(sprintf('method=%s', opt.name));
    for ni = 1:length(rp.nvec)
        n = rp.nvec(ni);
        disp(sprintf('n=%d',n));
        if rp.parallel
            parfor l = 1:length(loop)
                disp(sprintf('LOOP = %d', l));
                rng(l, 'twister'); % seed random numbers
                data = samples(bnet{l}, n);
                [G, ti(l)] = learn_structure(data, opt, rp, n);
                fprintf('TRUE PDAG:\n')
                rp.true_pdag
                fprintf('Learned PDAG:\n')
                dag_to_cpdag(G)
                s(l) = compute_shd(G, rp.true_pdag, false);
                printf(2, '%s: bnet=%d, nrep=%d, shd=%d\n', ...
                    opt.name, loop{l}.i, loop{l}.j, s(l));
            end
        else
            for l = 1:length(loop)
                disp(sprintf('LOOP = %d', l));
                rng(l, 'twister'); % seed random numbers
                data = samples(bnet{l}, n);
                [G, ti(l)] = learn_structure(data, opt, rp, n);
                fprintf('TRUE PDAG:\n')
                rp.true_pdag
                fprintf('Learned PDAG:\n')
                dag_to_cpdag(G)
                s(l) = compute_shd(G, rp.true_pdag, false);
                printf(2, '%s: bnet=%d, nrep=%d, shd=%d\n', ...
                    opt.name, loop{l}.i, loop{l}.j, s(l));
            end
        end
        [SHD{t}, S{t}, T{t}] = populate_SHD_ST(SHD{t}, S{t}, T{t}, rp, s, ti, ni);
        update_plot(S, T, t, ni, rp, learn_opt);
        if rp.save_flag
            eval(['save ' rp.matfile]);
        end
    end
end

[out.SHD, out.T, out.bn_opt, out.rp, out.learn_opt, out.bnet] ...
    = deal(SHD, T, bn_opt, rp, learn_opt, bn);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_plot(S, T, tmax, nmax, rp, learn_opt)
    if rp.plot_flag
        figure(1)
        hold on
        n = rp.nvec(1:nmax);
        [h1, h2] = deal(zeros(1, tmax));
        
        for t = 1:tmax
            subplot(1, 2, 1)
            hold on
            %s = squeeze(mean(mean(SHD{t}, 1), 2));
            s = mean(S{t}, 1);
            e = std(S{t}, 1);
            h1(t) = errorbar(n, s(1:nmax), e(1:nmax), learn_opt{t}.color, 'linewidth', 2);
            
            subplot(1, 2, 2)
            hold on
            time = squeeze(mean(mean(T{t}, 1), 2));
            h2(t) = plot(n, time(1:nmax), learn_opt{t}.color, 'linewidth', 2);
            leg{t} = learn_opt{t}.name;
        end
        
        subplot(1, 2, 1)
        xlabel('number of samples', 'fontsize', 14);
        ylabel('structural hamming distance', 'fontsize', 14);
        legend(h1, leg, 'fontsize', 12, 'location', 'Best');
        title(sprintf('Error, mean of %d bnets, %d reps', rp.num_bnet, rp.num_nrep));
        
        subplot(1, 2, 2);
        xlabel('number of samples', 'fontsize', 14);
        ylabel('run time (sec)', 'fontsize', 14)
        legend(h2, leg, 'fontsize', 12, 'location', 'Best');
        title('Runtime (sec)', 'fontsize', 14); 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bnet, bn] = generate_bnets(bn_opt, loop, num_bnet, data_gen)
    [bnet, bn] = deal({});
    for i = 1:num_bnet
        bn{i} = make_bnet(bn_opt);
    end
    if num_bnet > 1
        field = 'weights';
        if strcmpi(data_gen, 'random')
            field = 'cpt';
        end
        assert(~isequal(get_field(bn{1}.CPD{end}, field), ...
            get_field(bn{end}.CPD{end}, field)));
    end
    for l = 1:length(loop)
        bnet{l} = bn{loop{l}.i};
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SHD, S, T] = populate_SHD_ST(SHD, S, T, rp, s, t, ni)
    S(:, ni) = s;
    s = reshape(s, rp.num_nrep, rp.num_bnet)';
    t = reshape(t, rp.num_nrep, rp.num_bnet)';
    SHD(:, :, ni) = s;
    T(:, :, ni) = t;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rp, learn_opt, bn_opt, SHD, S, T] = init(in)
    [rp, learn_opt, max_arity] = init_bn_learn(in);
    [rp, SHD, S, T, bn_opt] = init_synthetic(learn_opt, rp, max_arity);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rp, SHD, S, T, bn_opt] = init_synthetic(learn_opt, rp, max_arity)
    SHD = cell(length(learn_opt), 1);
    S = cell(length(learn_opt), 1);
    T = cell(length(learn_opt), 1);
    for c = 1:length(learn_opt)
        SHD{c} = NaN*ones(rp.num_bnet, rp.num_nrep, length(rp.nvec));
        S{c} = NaN*ones(rp.num_bnet*rp.num_nrep, length(rp.nvec));
        T{c} = NaN*ones(rp.num_bnet, rp.num_nrep, length(rp.nvec));
    end
    
    % XXX is this really what I want?
    a = 1;
    if strcmpi(rp.data_gen, 'random')
        a = max_arity;
    end
    
    bn_opt = struct('network', rp.network, 'arity', a, ...
        'data_gen', rp.data_gen, 'variance', rp.variance, ...
        'moralize', false, 'n', rp.nvars, 'tile', rp.tile);
    rp.true_pdag = dag_to_cpdag(get_dag(bn_opt));
    
    if rp.save_flag
        dir_name = sprintf('results/%s', get_date());
        system(['mkdir -p ' dir_name]);
        rp.matfile = sprintf('%s/%s_%s.mat', dir_name, rp.network, func2str(rp.nfunc));
    end
    
end




