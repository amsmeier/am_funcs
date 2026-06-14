% generate versions of noise correlation table when considering locomotion trials, stationary trials, or all trials combined
% for reviewer 2 rec 1

paths = setpaths_locmod(); 
close all force
filetable = [paths.data, filesep,'analyses',filesep, 'analysis_master.xlsx']; 

pars.loc_range_mps =  [-inf inf];
[cortable, filetable] = batch_pairwise_cor(filetable,pars)
save([paths.data, filesep,'analyses',filesep, 'cor_all'])

pars.loc_range_mps =  [-inf 0.001];
[cortable, filetable] = batch_pairwise_cor(filetable,pars)
save([paths.data, filesep,'analyses',filesep, 'cor_stationary'])

pars.loc_range_mps =  [0.001 inf];
[cortable, filetable] = batch_pairwise_cor(filetable,pars)
save([paths.data, filesep, 'cor_locomoting'])
