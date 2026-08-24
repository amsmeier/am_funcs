
% load("C:\temp\F\20015\2020-05-18\tuningdat.mat")

close all

 paths = setpaths_locmod(); 

%%% check whether locomotion changes depends on stimulus identity
% for reviewer 3 public comment 1
%%% first load locomotion vs. stim parameters timepoints for each subject

rerun_tabulate_subjects = 1; % if true, regenerate and save the table; otherwise, try to load it from disk

op.stimparams_long = {"stim_sf_cyclesperdeg","stim_tf_hz","stim_orient_deg"}; % original names in events table 
    op.stimpars =    {"sf",                     "tf",       "orient"}; 
op.n_stimpars = length(op.stimparams_long); 

%% LOAD OR COMPILE DATA
if ~rerun_tabulate_subjects
    load([paths.analyses, filesep, 'stimparam_vs_locomotion']); 
else
    % load list of runs to analyze
    runs = readtable(paths.subjects_master); % load master file list
    runs.sub = cellstr(num2str(runs.sub));
    runs = runs(runs.analyze_plane == 1,:); % keep only planes that have be marked for analysis
    runs.analyze_plane = [];  
    [~, first_run_idx] = unique(runs(:, {'sub', 'day'}), 'stable'); % Find the indices of the first unique combination of subject and day
        runs = runs(first_run_idx, :); clear first_run_idx; % Filter the runs table to keep only those rows
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

        %%% a triawise locm vs. stimparam for this run to the all-runs table
        runs.locm_trials{irun} = tuningdat.tuningpars.locm_trials; 
    end
    
    % organize and save
    runs = movevars(runs,'ev','After','day');
    save([paths.analyses, filesep, 'stimparam_vs_locomotion'],'runs','op')
end

% %% generate plots for sf, tf, orient - scatter plot with point for each run, color coded by subject
% % this section looks at 'scope events'.... we should not use this discretization - instead discretize per trial
% 
% hfig = figure('Color','w','WindowState', 'maximized');
% subs = unique(runs.sub);
% subs = table(subs,'VariableNames',{'sub'});
% nsubs = height(subs);
% for ipar = op.n_stimpars
%     thispar_long = op.stimparams_long{ipar};
%     thispar = op.stimpars{ipar};
%     subplot(1,ipar,op.n_stimpars)
% 
%     for isub = 1:nsubs
%         thissub = subs.sub{isub};
% 
%         switch thispar
%             case {'sf','tf'}
% 
%                % get spearman correlation between locomotion and stim param value in this run 
%                 [rho,pval] = corr([runs.('ev'){irun}{:,thispar_long}, runs.('ev'){irun}{:,'locomotion_forw_mpersec'}] ,'Type','Spearman', 'rows','complete')
%             case 'orient'
% 
%         end
%     end
% 
% end

%% trial to trial locm vs. stim param

% hfig = figure('Color','w','WindowState', 'maximized');
subs = table(unique(runs.sub),'VariableNames',{'sub'},'RowNames',unique(runs.sub));
    nsubs = height(subs);
    subs.locm_trials_sf = cell(nsubs,1);
    subs.locm_trials_tf = cell(nsubs,1);
    subs.locm_trials_orient = cell(nsubs,1);


for ipar = 1:op.n_stimpars
    thispar_long = op.stimparams_long{ipar};
    thispar = op.stimpars{ipar};
    hfig = figure;

    for isub = 1:nsubs
        thissub = subs.sub{isub};
        
        runs_this_sub_idx = find(ismember(runs.sub, thissub)); 
        nruns_this_sub = length(runs_this_sub_idx); 
        locm_trials_thispar = cell(1,nruns_this_sub);
        subs{thissub,['locm_trials_',char(thispar)]} = {cell(1,nruns_this_sub)}; 

        for irun_this_sub = 1:length(runs_this_sub_idx)
            run_idx = runs_this_sub_idx(irun_this_sub); 
            % locm_trials_thispar{irun_this_sub} = runs.locm_trials{run_idx}; % store trial locm data for this run for this subject
        

            switch thispar
                case {'sf','tf'}
                    % % % simple corr:
                    % % % parvals = runs.locm_trials{run_idx}.(thispar){:,thispar}; 
                    % % % locm_vals = runs.locm_trials{run_idx}.(thispar).locm_forw_mps; 
                    % % % [h p] = corrcoef(repmat(parvals,1,size(locm_vals,2)),...
                    % % %     locm_vals, 'Rows', 'complete');
     
                case 'orient'
    
            end

            subs{thissub,['locm_trials_',char(thispar)]}{1}{1,irun_this_sub} = runs.locm_trials{run_idx}.(thispar); 


        end

        % from locm_trial_thispar, generate plot of this par for this subject
        %%% one bar plus error bars for each run


        % subplot(2,5,isub)


    end

end

%% plotting slope of locomotion against parameter for each run for each mouse
%% plotting slope of locomotion against parameter for each run for each mouse
num_params = length(op.stimpars);
nsubs = height(subs); % Total number of mice

% Pre-calculate subplot grid dimensions (e.g., 3x3 layout for 9 mice)
num_cols = min(3, nsubs);
num_rows = ceil(nsubs / num_cols);

for p = 1:num_params
    param_name = char(op.stimpars{p}); 
    col_name = ['locm_trials_' param_name]; 
    
    % Create one figure per parameter, set background to white ('Color', 'w')
    figure('Name', sprintf('Param: %s - Speed Slopes Across Mice', param_name), ...
           'WindowState', 'maximized', 'Color', 'w'); 
           
    for mouse_idx = 1:nsubs
        mouse_id = char(subs.sub{mouse_idx});
        
        % Extract the 1xN cell array of run tables for this specific mouse and parameter
        runs_cell = subs.(col_name){mouse_idx}; 
        
        % Handle edge cases where data might not be populated yet
        if isempty(runs_cell) || isempty(runs_cell{1})
            continue; 
        end
        
        num_runs = length(runs_cell);
        
        % Initialize arrays to hold bar heights (slopes/amplitudes) and error bounds
        slopes = NaN(1, num_runs);
        err_neg = NaN(1, num_runs);
        err_pos = NaN(1, num_runs);
        
        for r = 1:num_runs
            run_table = runs_cell{r};
            if isempty(run_table)
                continue; % Skip if the run is empty
            end
            
            % 1. Extract the stimulus parameters
            param_vals = run_table.(param_name);
            [~, ~, param_ranks] = unique(param_vals); 
            
            % 2. Extract locomotion matrix (Rows = Stim levels, Cols = Trials)
            locm_data = run_table.locm_forw_mps;
            
            % 3. Flatten data into trial-by-trial (X, Y) vectors
            X = [];
            Y = [];
            for i = 1:length(param_ranks)
                trials_for_param = locm_data(i, :);
                trials_for_param = trials_for_param(~isnan(trials_for_param)); 
                
                if strcmp(param_name, 'orient')
                    % For circular data (0-360 drifting gratings), use radians
                    val = param_vals(i) * (pi / 180); 
                else
                    % For sf and tf, use ordinal ranks
                    val = param_ranks(i); 
                end
                
                X = [X; repmat(val, length(trials_for_param), 1)];
                Y = [Y; trials_for_param'];
            end
            
            % 4. Fit the appropriate model
            if length(Y) > 2 
                if strcmp(param_name, 'orient')
                    % --- Circular-Linear Regression (Amplitude) ---
                    X_cos = cos(X);
                    X_sin = sin(X);
                    mdl = fitlm([X_cos, X_sin], Y);
                    
                    % Calculate tuning amplitude
                    beta_cos = mdl.Coefficients.Estimate(2);
                    beta_sin = mdl.Coefficients.Estimate(3);
                    amplitude = sqrt(beta_cos^2 + beta_sin^2);
                    slopes(r) = amplitude;
                    
                    % Bootstrap 95% CI for the amplitude
                    n_boot = 500;
                    boot_amps = NaN(n_boot, 1);
                    for b = 1:n_boot
                        idx = randi(length(Y), length(Y), 1); % Resample with replacement
                        b_mdl = fitlm([X_cos(idx), X_sin(idx)], Y(idx));
                        boot_amps(b) = norm(b_mdl.Coefficients.Estimate(2:3));
                    end
                    ci = prctile(boot_amps, [2.5, 97.5]);
                    
                    err_neg(r) = amplitude - ci(1);
                    err_pos(r) = ci(2) - amplitude;
                    
                else
                    % --- Standard OLS (Slope) for sf and tf ---
                    mdl = fitlm(X, Y);
                    slope = mdl.Coefficients.Estimate(2); 
                    ci = mdl.coefCI; 
                    
                    slopes(r) = slope;
                    err_neg(r) = slope - ci(2,1); 
                    err_pos(r) = ci(2,2) - slope; 
                end
            end
        end
        
        % --- Plotting ---
        subplot(num_rows, num_cols, mouse_idx);
        
        % Draw the bars with a gray face color
        b = bar(1:num_runs, slopes, 'FaceColor', [0.7 0.7 0.7]);
        hold on;
        
        % Draw the error bars
        errorbar(1:num_runs, slopes, err_neg, err_pos, 'k.', ...
            'LineWidth', 1.5, 'CapSize', 10);
            
        % Add a zero-line to easily see which error bars cross zero
        yline(0, 'k--', 'LineWidth', 1);
        
        % Formatting
        xlabel('Run');
        if strcmp(param_name, 'orient')
            ylabel('Tuning Amplitude');
        else
            ylabel('Slope (\Delta speed per rank)');
        end
        xticks(1:num_runs);
        box off;
        set(gca, 'TickDir', 'out');
    end
    
    % Overall title for the entire figure
    if strcmp(param_name, 'orient')
        sgtitle(sprintf('Trial Speed Tuning Amplitude vs. %s', param_name), 'Interpreter', 'none');
    else
        sgtitle(sprintf('Linear Trend of Trial Speed vs. %s Rank', param_name), 'Interpreter', 'none');
    end
end