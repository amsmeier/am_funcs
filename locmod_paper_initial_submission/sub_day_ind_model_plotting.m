%%%% make 2 supplementary fig plots related to subject-relative day index
% run tuning_stats.m, plot_param_per_lvl2_var.m, and compare_and_plot_linear_models.m before running this script
%
% make sure that model_ops.lvl2var = 'sub_day_ind' in plot_param_per_lvl2_var.m
% .... and that ops.varname = 'pakan_loc_index' in tuning_stats.m

both_plots_in_1_fig = 0; % stack figures using tiledlayout

%% plot locmod vs sub_day_ind

close all

%%%%%%%%% params

subdayind_plot_ops.ebar_thickness = 2;   
subdayind_plot_ops.ebar_cap_size = 4.5;   
subdayind_plot_ops.ebar_color = [0 0 0]; 
subdayind_plot_ops.font_name = 'Arial'; 
subdayind_plot_ops.axis_thickness = 4; % does not apply to violin; fig s1 quants
subdayind_plot_ops.bar_color = [0.5 0.5 0.5]; 
subdayind_plot_ops.bargraph_line_width = 3;
subdayind_plot_ops.axis_font_bold = 1; % font bold or not bold
subdayind_plot_ops.axis_font_size = 19;


 %%%%%%% make plots


hfig_lvl2 = figure; 

if both_plots_in_1_fig
    tiledlayout(2,1)
    nexttile
end

hbar_subdayind = bar(lvl2stats{:,['mean_', ops.varname]});
hold on
hebar_subdayind = errorbar(1:nlvl2var_levels, lvl2stats{:,['mean_', ops.varname]}, lvl2stats{:,['sem_', ops.varname]},...
    '.','Color',subdayind_plot_ops.ebar_color, 'linestyle','none');
hax_subdayind = gca; 

[lvl2_anovap, lvl2_anovatab, lvl2_anovastats] = anova1(roitable{ops.meets_criteria,ops.varname}, roitable{ops.meets_criteria, model_ops.lvl2var}, 'off');
[r_corr_lvl2, p_corr_lvl2] = corrcoef(roitable{ops.meets_criteria,ops.varname}, roitable{ops.meets_criteria, model_ops.lvl2var});

ylabel('Locomotion Modulation Index')
xlabel('Session number')

hbar_subdayind.LineWidth = subdayind_plot_ops.bargraph_line_width;
hbar_subdayind.FaceColor = subdayind_plot_ops.bar_color; 
hbar_subdayind.LineWidth = subdayind_plot_ops.bargraph_line_width; 
% hax_subdayind.XTick = []; 

hax_subdayind.FontName = subdayind_plot_ops.font_name;
hax_subdayind.FontSize = subdayind_plot_ops.axis_font_size;
hax_subdayind.LineWidth = subdayind_plot_ops.axis_thickness;
hebar_subdayind.LineWidth = subdayind_plot_ops.ebar_thickness; % set errorbar line width
hebar_subdayind.Color = subdayind_plot_ops.ebar_color; % set errorbar line color
hebar_subdayind.CapSize = subdayind_plot_ops.ebar_cap_size; 

if subdayind_plot_ops.axis_font_bold; set(hax_subdayind,'FontWeight','bold'); end
% set(hax_subdayind,'LooseInset',get(hax_subdayind,'TightInset')+[0 0 0.005 0]) % crop borders
set(hax_subdayind,'Box','off')




%% plot AIC of selected models



%%%%%%%%% params

aic_plot_ops.font_name = 'Arial'; 
aic_plot_ops.axis_thickness = 4; % does not apply to violin; fig s1 quants
aic_plot_ops.bar_color = [0.5 0.5 0.5]; 
aic_plot_ops.bargraph_line_width = 3;
aic_plot_ops.axis_font_bold = 1; % font bold or not bold
aic_plot_ops.axis_font_size = 19;
aic_plot_ops.xlim = [0.2 4.8]; 


model_formulas_to_plot = {[ops.varname, ' ~ 1'];... %%% intercept only
     [ops.varname, ' ~ 1 + ', ops.sorting_var];.... %%% add sorting variable (ie patch vs. interpatch) as level 1 predctors 
     [ops.varname, ' ~ 1 + sub_day_ind'];.... 
     [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + sub_day_ind'];.... 
%      [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + day'];.... 
%      [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + (1|sub)'];.... %%%%% use sub as level 2 predictor
%      [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + sub_day_ind + (1|sub)'];....  
     };

 xtick_label_rotation = 0; 
 ylim_factor = [0.3, 0.5]; 

 
 %%%%%%% make plots
 
 
if both_plots_in_1_fig
    nexttile
elseif ~both_plots_in_1_fig
    close all
    hfig_aic = figure; 
end
 
 n_models_to_plot = length(model_formulas_to_plot);
aic_to_plot = nan(n_models_to_plot,1);
 for imodel = 1:n_models_to_plot
    thismodel = model_formulas_to_plot{imodel};
    modeltab_ind = strcmp(modeltab.formula_str, thismodel);
    aic_to_plot(imodel) = modeltab.aic(modeltab_ind);
 end
 
 plotmodels = table(model_formulas_to_plot, aic_to_plot, model_formulas_to_plot, 'VariableNames',....
                    {'formula',             'aic',          'xname'}                );
 
 plotmodels.xname = strrep(plotmodels.xname,{'pakan_loc_index'},{'LMI'}); 
plotmodels.xname = strrep(plotmodels.xname,{'sub_day_ind'},{'\newline Session number'}); 
plotmodels.xname = strrep(plotmodels.xname,{'quantile'},{'\newline Quantile'}); 
plotmodels.xname = strrep(plotmodels.xname,{'inpatch'},{'\newline Module'}); 

hbar_aic = bar(plotmodels.aic);
hax_aic = gca;
hax_aic.XTickLabels = plotmodels.xname;
hax_aic.XTickLabelRotation = xtick_label_rotation; 
ylimits = [min(plotmodels.aic) - ylim_factor(1)*range(plotmodels.aic), max(plotmodels.aic) + ylim_factor(2)*range(plotmodels.aic)] ;
ylim(ylimits)
ylabel('Akaike Information Criterion')

hbar_aic.LineWidth = aic_plot_ops.bargraph_line_width;
hbar_aic.FaceColor = aic_plot_ops.bar_color; 
hbar_aic.LineWidth = aic_plot_ops.bargraph_line_width; 
% hax_subdayind.XTick = []; 

hax_aic.FontName = aic_plot_ops.font_name;
hax_aic.FontSize = aic_plot_ops.axis_font_size;
hax_aic.LineWidth = aic_plot_ops.axis_thickness;

xlim(aic_plot_ops.xlim)

if aic_plot_ops.axis_font_bold; set(hax_aic,'FontWeight','bold'); end
% set(hax_aic,'LooseInset',get(hax_aic,'TightInset')+[0 0 0.005 0]) % crop borders
set(hax_aic,'Box','off')




