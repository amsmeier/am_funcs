% set paths for locomotion-modules project in Burkhalter lab [2019-2026]

function [paths, compname] = setpaths_locmod()

% if a paths variable wasn't provided, create a new one
if ~exist('paths','var')
    paths = struct; 
end

compname = getenv('COMPUTERNAME');

paths.code = 'C:\docs\code\am_funcs'; 
paths.util = [paths.code, filesep, 'util'];
paths.tuning = [paths.code, filesep, 'tuning_curves'];
    paths.tuning_fitting = [paths.tuning, filesep, 'tuning_curve_fitting']; 
paths.cor_code = [paths.code, filesep, 'cor']; % correlation analysis code
paths.fig_funcs = [paths.code, filesep, 'fig_funcs'];
paths.downloaded = [paths.code, filesep, 'downloaded'];
    paths.gaussfit = [paths.downloaded, filesep, 'gaussfit']; 

paths.data = 'C:\Dropbox\wustl'; 

 paths_to_add =  {paths.code;...
     paths.util;...
     paths.tuning;...
     paths.tuning_fitting;...
     paths.cor_code;... 
     paths.fig_funcs;...
     paths.downloaded;...
     paths.gaussfit;...
     paths.data;...

};

 addpath(paths_to_add{:});