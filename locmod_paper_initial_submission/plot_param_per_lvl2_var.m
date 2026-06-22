% % plot_param_per_lvl2var
%%% plot parameters (like locomotion modulation) per level of lvl2 variable, like subject or date
%%% 
%%% before running this script, run tuning_stats.m generate the ops.meets_criteria vector
%%% .... ops.varname will be carried over from tuning_stats.m
%%%
%%% this script will run a multilevel GLM with random intercepts and a as level-2 variable
% 
%%%% this script can be called for batch processing with compare_and_plot_linear_models.m

% close all

xtick_label_rotation = 75; 

vardefault('model_ops',struct); % parameters for linear model
field_default('model_ops','covariance_struct','Diagonal'); 
field_default('model_ops','lvl2var','sub_day_ind'); %%%% only affects plotting, not the actual model
field_default('model_ops','formula',[ops.varname, ' ~ 1 + ', ops.sorting_var, ' + (1|', model_ops.lvl2var, ')']); 
field_default('model_ops', 'plot_fitted_vs_actual', 1); % compare mean value across lvl2 val to the fitted values across lvl2 val
field_default('model_ops', 'plot_individual_lvl2_val', 1) % compare main dependent variable (e.g. pakan loc mod) across the sorting variable (module or quantile) and across lvl2 val

model_ops.formula = 'pakan_loc_index ~ 1 + inpatch';
% model_ops.formula = 'pakan_loc_index ~ 1 + quantile';
% model_ops.formula = 'pakan_loc_index ~ 1 + inpatch + day';
% model_ops.formula = 'pakan_loc_index ~ 1 + quantile + day';
% model_ops.formula = 'pakan_loc_index ~ 1 + quantile + (1|day)';
% model_ops.formula = 'pakan_loc_index ~ 1 + quantile + sub_day_ind';
% model_ops.formula = 'pakan_loc_index ~ 1 + inpatch + (1|sub_day_ind)';
% model_ops.formula = 'pakan_loc_index ~ 1 + inpatch + sub_day_ind';
% model_ops.formula = 'pakan_loc_index ~ 1 + inpatch + sub_day_ind + (1|sub)';
% model_ops.formula = 'pakan_loc_index ~ 1 + quantile + sub_day_ind + (1|sub)';
% model_ops.formula = 'pakan_loc_index ~ 1 + quantile + sub_day_ind + sub';
% model_ops.formula = 'pakan_loc_index ~ 1 + inpatch + (1|sub)';
% model_ops.formula = 'pakan_loc_index ~ 1 + quantile + (1|sub)';
% model_ops.formula = 'pakan_loc_index ~ 1 + quantile + sub';
% model_ops.formula = 'pakan_loc_index ~ 1 + sub_day_ind';

% model_ops.formula = 'orient_si ~ 1 + quantile';

% multilevel model
lme = fitlme(roitable(ops.meets_criteria,:), model_ops.formula, 'CovariancePattern', model_ops.covariance_struct)
fixed_coef = dataset2table(lme.Coefficients);
[rand_coef,rand_names,rand_stats] = randomEffects(lme);
intercept_overall_row = strcmp(fixed_coef.Name, '(Intercept)');
intercept_overall = fixed_coef.Estimate(intercept_overall_row);
lvl2stats = grpstats(roitable(ops.meets_criteria,{ops.varname,model_ops.lvl2var,ops.sorting_var}),model_ops.lvl2var,["mean","sem","std","range","min","max",]);
nlvl2var_levels = length(unique(roitable{ops.meets_criteria,model_ops.lvl2var}));
n_sorting_labels = length(labelnames); 

% split response variable across the sorting variable (module or quantile) and across lvl2 val
lvl2stats.outcome_by_label_mean = nan(nlvl2var_levels, n_sorting_labels);
lvl2stats.outcome_by_label_std = nan(nlvl2var_levels, n_sorting_labels);
lvl2stats.outcome_by_label_n = nan(nlvl2var_levels, n_sorting_labels);

for ilvl2 = 1:nlvl2var_levels
    if isnumeric(lvl2stats{ilvl2,model_ops.lvl2var})
        this_lvl2val = lvl2stats{ilvl2,model_ops.lvl2var}; 
        lvl2_row_match = lme.Variables{:,model_ops.lvl2var} == this_lvl2val; 
    else
        this_lvl2val = lvl2stats{ilvl2,model_ops.lvl2var}{:}; 
        lvl2_row_match = strcmp(lme.Variables{:,model_ops.lvl2var},this_lvl2val); % need to customize depending on whether lvl2var is string or number
    end
    for ilabel = 1:n_sorting_labels
        thislabel = labelnames(ilabel); 
        rowmatch = lvl2_row_match & lme.Variables{:,ops.sorting_var} == thislabel; % cells in this lvl2var level and with this sorting group label
        vals_this_group_this_lvl2 = lme.Variables{rowmatch,ops.varname};  
        lvl2stats.outcome_by_label_mean(ilvl2,ilabel) = mean(vals_this_group_this_lvl2);
        lvl2stats.outcome_by_label_std(ilvl2,ilabel) = std(vals_this_group_this_lvl2);
        lvl2stats.outcome_by_label_n(ilvl2,ilabel) = length(vals_this_group_this_lvl2);
        lvl2stats.outcome_by_label_sem(ilvl2,ilabel) = std(vals_this_group_this_lvl2) ./ sqrt(lvl2stats.outcome_by_label_n(ilvl2,ilabel));
    end
end

%% plotting


% % % % plot P vs IP within each mouse
% % % bar(rand_stats.Estimate + intercept_overall)

%% compare mean value across lvl2var level to the fitted values across lvl2var level
if model_ops.plot_fitted_vs_actual
    bar([rand_stats.Estimate + intercept_overall, lvl2stats{:,['mean_',ops.varname]}]); 
        ylabel([ops.varname])
        legend({'fitted', 'real mean'})
        hax = gca;
%         hax.XTickLabels = num2str(lvl2stats{model_ops.lvl2var});  % need to customize depending on whether lvl2var is string or number
          hax.XTickLabels = lvl2stats{:,model_ops.lvl2var};
        xlabel(model_ops.lvl2var)
end
        
%% compare main dependent variable (e.g. pakan loc mod) across the sorting variable (module or quantile) and across lvl2 val

if model_ops.plot_individual_lvl2_val

    ebar_vals = lvl2stats.outcome_by_label_sem;

%     close all
    figure 
    tiledlayout(2,1)
    nexttile
    hold off
    hbar = bar(lvl2stats.outcome_by_label_mean);
    hold on

    clear xlocs
    for ibar = 1:length(hbar)
        xlocs(ibar,:) = hbar(ibar).XEndPoints;
    end
    errorbar(xlocs', lvl2stats.outcome_by_label_mean, ebar_vals, 'k', 'linestyle','none')
    ylabel('locomotion modulation index')
    hax = gca;
    hax.XTick = 1:nlvl2var_levels; 
    hax.XTickLabelRotation = xtick_label_rotation; 
%     hax.XTickLabels = num2str(lvl2stats{model_ops.lvl2var});  % need to customize depending on whether lvl2var is string or number
    hax.XTickLabels = lvl2stats{:,model_ops.lvl2var};
    xlabel(model_ops.lvl2var)
    legend({'M2- interpatch','M2+ patch'})
    ylim([-0.05 0.4])
    hax.ColorOrder(1:2, :) = [0 1 0; 1 0 1];

    nexttile
    bar(sum(lvl2stats.outcome_by_label_n,2))
    hax2 = gca;
    hax2.XTick = 1:nlvl2var_levels; 
    hax2.XTickLabelRotation = xtick_label_rotation; 
    %     hax.XTickLabels = num2str(lvl2stats{model_ops.lvl2var});  % need to customize depending on whether lvl2var is string or number
    hax2.XTickLabels = lvl2stats{:,model_ops.lvl2var};
    ylabel('number of cells')
end
