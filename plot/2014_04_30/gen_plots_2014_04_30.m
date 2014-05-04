clear all
close all

load results/2014_04_30/child_quadratic_arity3_N100/child_quadratic_arity3_N100.mat

options = {struct('classifier', @kci_classifier, 'discretize',false,...
    'prealloc', @kci_prealloc, 'kernel', L,'thresholds', thresholds, ...
    'color', 'g-' ,'params',[],'normalize',true,'name','partial corr, cts data'), ...
    
    struct('classifier', @kci_classifier, 'discretize', false, ...
    'prealloc', @kci_prealloc, 'kernel', G, 'thresholds', thresholds, ...
    'color', 'b-','params',[],'normalize',true,'name','KCI gauss kernel, cts data'), ...
    
    struct('classifier', @kci_classifier, 'discretize',true, ...
    'prealloc', @kci_prealloc, 'kernel', L,'thresholds', thresholds, ...
    'color', 'g--' ,'params',[],'normalize',true,'name',sprintf('partial corr, arity=%d',arity)), ...
    
    struct('classifier', @kci_classifier,'discretize',true,...
    'prealloc', @kci_prealloc, 'kernel', G, 'thresholds', thresholds, ...
    'color', 'b--','params',[],'normalize',true,'name',sprintf('KCI gauss kernel, arity=%d',arity)), ...
    
    struct('classifier', @cc_classifier, 'discretize',true, ...
    'prealloc', @dummy_prealloc, 'kernel', empty, 'thresholds', thresholds, ...
    'color', 'r:','params',[],'normalize',false,'name',sprintf('cond corr, arity=%d',arity)), ...
    
    struct('classifier', @mi_classifier,'discretize',true, ...
    'prealloc', @dummy_prealloc, 'kernel', empty, 'thresholds', thresholds_mi, ...
    'color', 'm-.','params',[],'normalize',false,'name',sprintf('cond MI, arity=%d',arity))};

plot_roc_multi
%title(sprintf('Child network with quadratic gaussian CPDs, N=100, 20 experiments'),'fontsize',14);
title('Child network','fontsize',14);
%set(gcf, 'units','inches', 'position', [5 5 6 4]);
xlim([0 1]);
ylim([0 1]);

clear all;
figure
load ins_quadratic_arity3_N100
plot_roc_multi
%title(sprintf('Insurance network with quadratic gaussian CPDs, N=100, 20 experiments'),'fontsize',14);
title('Insurance network','fontsize',14);
%set(gcf, 'units','inches', 'position', [5 5 6 4]);
xlim([0 1]);
ylim([0 1]);



