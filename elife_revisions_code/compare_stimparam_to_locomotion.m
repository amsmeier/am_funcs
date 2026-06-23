%%% check whether locomotion changes depends on stimulus identity
% for reviewer 3 public comment 1
%%% first load locomotion vs. stim parameters timepoints for each subject

rerun_tabulate_subjects = 1; % if true, regenerate and save the table; otherwise, try to load it from disk

op.stimparams_long = {"stim_sf_cyclesperdeg","stim_tf_hz","stim_orient_deg"}; % original names in events table 
    op.stimpars =    {"sf",                     "tf",       "orient"}; 
op.n_stimpars = length(op.stimparams_long); 

if ~rerun_tabulate_subjects
    load([paths.analyses, filesep, 'stimparam_vs_locomotion']); 
else
    % load list of runs to analyze
    paths = setpaths_locmod(); 
    runs = readtable(paths.subjects_master); % load master file list
    runs = runs(runs.analyze_plane == 1,:); % keep only planes that have be marked for analysis
    runs.analyze_plane = [];  
    runs = replace_table_strings(runs,'F:',paths.data); %  replace "F:" in every path of analysis_master.xlxs with the actual data path of the computer
    nruns = height(runs);
    runs.ev = cell(nruns,1); 
    
    for irun = 1:nruns
        irun
        clear tuningdat ev
        load([runs.directory{irun}, filesep, runs.tuning_file{irun}],'tuningdat'); % contains stim and locm data for this run
        ev = tuningdat.scope_events; 
        runs.ev{irun} = table(ev.onset, ev.locomotion_forw_mpersec, ev.stim_present, ev.stim_orient_deg, ev.stim_sf_cyclesperdeg, ev.stim_tf_hz, ev.stim_diam_deg,'VariableNames',...
                               { 'onset', 'locomotion_forw_mpersec',  'stim_present',  'stim_orient_deg', 'stim_sf_cyclesperdeg',   'stim_tf_hz', 'stim_diam_deg'});
        % for ipar = 1:op.n_stimpars
        % 
        % end
    end
    
    % organize and save
    runs = movevars(runs,'ev','After','day');
    save([paths.analyses, filesep, 'stimparam_vs_locomotion'],'runs','op')
end

%% generate plots for sf, tf, orient - scatter plot with point for each run, color coded by subject

hfig = figure('Color','w','WindowState', 'maximized');
for ipar = op.n_stimpars
    thispar_long = op.stimparams_long{ipar};
    thispar = op.stimpars{ipar};
    subplot(1,ipar,n_stimpars)

    switch thispar
        case {'sf','tf'}

        case 'orient'

    end
    

end