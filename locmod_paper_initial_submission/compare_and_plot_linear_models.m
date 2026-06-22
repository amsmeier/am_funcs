 %%%% run linear mixed effects models on gcamp response data
 % .... plot results from different models
 % .... this script will call plot_param_per_subject.m for each model to run
%
 %  tuning_stats.m must be run to load and process the roi table before running this script

 
 %%%%%%%%%% params
 
 model_ops.covariance_struct = 'Diagonal';
 model_ops.plot_fitted_vs_actual = 0; 
 model_ops.plot_individual_subjects = 0; 
 
 leading_vars = {'name','formula_str','aic','bic','LogLikelihood','deviance','CovariancePattern','NumPredictors','NumVariables','ResponseName'};
 
 



 % model_formulas = {[ops.varname, ' ~ 1'];... %%% intercept only
 %     [ops.varname, ' ~ 1 + ', ops.sorting_var];.... %%% add sorting variable (ie patch vs. interpatch) as level 1 predctors 
 %     [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + sub_day_ind'];.... 
 %     [ops.varname, ' ~ 1 + sub_day_ind'];.... 
 %     [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + day'];.... 
 %     [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + (1|sub)'];.... %%%%% use sub as level 2 predictor
 %     [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + sub_day_ind + (1|sub)'];....  
 %     };
 % model_names = {'intercept';...
 %     'quantile';...
 %     'quantile_dayind';...
 %     'dayind';...
 %     'quantile_day';...
 %     'quantile_sub-lvl2';...
 %     'quantile_dayind_sub-lvl2';...
 %     };
 
% model_formulas = {[ops.varname, ' ~ 1 '];... %%% intercept only
%      [ops.varname, ' ~ 1 + ', ops.sorting_var];.... %%% add sorting variable (ie patch vs. interpatch) as level 1 predctors 
%      % [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + (1|sub)'];.... %%%% use subject as level 2 predictor
%      [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + (1|day)'];.... %%%% use run day as level 2 predictor
%      % [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + day + (1|sub)'];.... %%%% add run date as level 1 predictor
%      };
%  model_names = {'intercept';...
%      'module';...
%      % 'module_sub';...
%      'module_day';...
%      % 'module_sub_day';...
%      };

 model_formulas = {[ops.varname, ' ~ 1'];... %%% intercept only
     [ops.varname, ' ~ 1 + ', ops.sorting_var];.... %%% add sorting variable (ie patch vs. interpatch) as level 1 predictors 
     [ops.varname, ' ~ 1 + sub_day_ind'];.... 
     [ops.varname, ' ~ 1 + ', ops.sorting_var, ' + sub_day_ind'];.... 
     };
 model_names = {'intercept';...
     'module';...
     'dayind';...
     'module_dayind';...
     };
 
 
 
%%%%%%%%%%% run models
 nmodels = length(model_formulas);
 nancol = nan(nmodels,1); 
 modeltab = table(model_names,model_formulas, 'VariableNames',...
                    {'name',    'formula_str'        });
temptab = table;
                
for imodel = 1:nmodels
    model_ops.formula = model_formulas{imodel};
    plot_param_per_subject()
    lme_struct=renameStructField(struct(lme),'VariableNames','VarNames');
    lme_struct = rmfield(lme_struct,{'Variables','Data'}); % redundant, large fields
    lme_struct.aic = lme_struct.ModelCriterion{1,1}; 
    lme_struct.bic = lme_struct.ModelCriterion{1,2}; 
    lme_struct.deviance = lme_struct.ModelCriterion{1,4}; 
    lmetabtemp = struct2table(lme_struct,'AsArray',1); % temporary table for 1 model
    lmetabtemp.PredLocs = {lmetabtemp.PredLocs}; % make 1x1 so we can concat
    lmetabtemp.CoefficientNames = {lmetabtemp.CoefficientNames}; % make 1x1 so we can concat
    lmetabtemp.Coefficients = {lmetabtemp.Coefficients}; % make 1x1 so we can concat
    temptab = [temptab; lmetabtemp]; % temporary table for all models
end

modeltab = [modeltab, temptab]; 
modeltab = movevars(modeltab,leading_vars,'Before',1);
clear temptab lme_struct lmetabtemp