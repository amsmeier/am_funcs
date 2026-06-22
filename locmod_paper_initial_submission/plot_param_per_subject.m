% plot_param_per_subject
%%% plot parameters (like locomotion modulation) per individual mouse
%%% 
%%% before running this script, run tuning_stats.m generate the ops.meets_criteria vector
%%% .... ops.varname will be carried over from tuning_stats.m
%%%
%%% this script will run a multilevel GLM with random intercepts and subject as level-2 variable
% 
%%%% this script can be called for batch processing with compare_and_plot_linear_models.m

vardefault('model_ops',struct); % parameters for linear model
field_default('model_ops','covariance_struct','Diagonal'); 
field_default('model_ops','formula',[ops.varname, ' ~ 1 + ', ops.sorting_var, ' + (1|sub)']); 
field_default('model_ops', 'plot_fitted_vs_actual', 1); % compare mean value across subjects to the fitted values across subjects
field_default('model_ops', 'plot_individual_subjects', 1) % compare main dependent variable (e.g. pakan loc mod) across the sorting variable (module or quantile) and across subjects

% multilevel model
lme = fitlme(roitable(ops.meets_criteria,:), model_ops.formula, 'CovariancePattern', model_ops.covariance_struct);
fixed_coef = dataset2table(lme.Coefficients);
[rand_coef,rand_names,rand_stats] = randomEffects(lme);
intercept_overall_row = strcmp(fixed_coef.Name, '(Intercept)');
intercept_overall = fixed_coef.Estimate(intercept_overall_row);
substats = grpstats(roitable(ops.meets_criteria,{ops.varname,'sub',ops.sorting_var}),'sub',["mean","sem","std","range","min","max",]);
nsubs = length(unique(roitable.sub(ops.meets_criteria)));
n_sorting_labels = length(labelnames); 

% split response variable across the sorting variable (module or quantile) and across subjects
substats.outcome_by_label_mean = nan(nsubs, n_sorting_labels);
substats.outcome_by_label_std = nan(nsubs, n_sorting_labels);
substats.outcome_by_label_n = nan(nsubs, n_sorting_labels);

for isub = 1:nsubs
    thissub = substats.sub(isub); 
    sub_row_match = lme.Variables.sub==thissub; 
    for ilabel = 1:n_sorting_labels
        thislabel = labelnames(ilabel); 
        rowmatch = sub_row_match & lme.Variables{:,ops.sorting_var} == thislabel; % cells in this subject and with this sorting group label
        vals_this_group_this_sub = lme.Variables{rowmatch,ops.varname};  
        substats.outcome_by_label_mean(isub,ilabel) = mean(vals_this_group_this_sub);
        substats.outcome_by_label_std(isub,ilabel) = std(vals_this_group_this_sub);
        substats.outcome_by_label_n(isub,ilabel) = length(vals_this_group_this_sub);
        substats.outcome_by_label_sem(isub,ilabel) = std(vals_this_group_this_sub) ./ sqrt(substats.outcome_by_label_n(isub,ilabel));
    end
end

%% plotting
close all

% % % % plot P vs IP within each mouse
% % % bar(rand_stats.Estimate + intercept_overall)

%% compare mean value across subjects to the fitted values across subjects
if model_ops.plot_fitted_vs_actual
    bar([rand_stats.Estimate + intercept_overall, substats{:,['mean_',ops.varname]}]); 
        ylabel([ops.varname])
        legend({'fitted', 'real mean'})
        hax = gca;
        hax.XTickLabels = num2str(substats.sub);
        xlabel('subject')
end
        
%% compare main dependent variable (e.g. pakan loc mod) across the sorting variable (module or quantile) and across subjects

if model_ops.plot_individual_subjects

    % ebar_vals = substats.outcome_by_label_std;
    ebar_vals = substats.outcome_by_label_sem;

    % close all
    figure 
    tiledlayout(2,1)
    nexttile
    hold off
    hbar = bar(substats.outcome_by_label_mean);
    hold on

    for ibar = 1:length(hbar)
        xlocs(ibar,:) = hbar(ibar).XEndPoints;
    end
    errorbar(xlocs', substats.outcome_by_label_mean, ebar_vals, 'k', 'linestyle','none')
    ylabel('locomotion modulation index')
    hax = gca;
    hax.XTickLabels = num2str(substats.sub);
    xlabel('subject')
    legend({'M2- interpatch','M2+ patch'})
    ylim([-0.05 0.4])
    hax.ColorOrder(1:2, :) = [0 1 0; 1 0 1];

    nexttile
    bar(sum(substats.outcome_by_label_n,2))
    ylabel('number of cells')
end
