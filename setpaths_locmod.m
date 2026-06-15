% set paths for locomotion-modules project in Burkhalter lab [2019-2026]

function [paths, compname] = setpaths_locmod(paths)

% if a paths variable wasn't provided, create a new one
if ~exist('paths','var')
    paths = struct; 
end

compname = getenv('COMPUTERNAME');

switch compname 
    case 'AMSMEIER' % AM Strix laptop
        paths.code = 'C:\docs\code\am_funcs'; 
        paths.data = 'C:\temp\F';

    case '677-GUE-WL-0010' % work thinkpad x1
        paths.code = 'C:\docs\code\am_funcs'; 
        paths.data = 'C:\Dropbox\wustl'; 

    case  'DESKTOP-H739EDS' %%%%%%% thermaltake - former AB lab computer 
        paths.code = 'C:\Users\Burkhalter Lab\Documents\matlab_functions\am_funcs'; 
        paths.data = 'F:\'; 
end

paths.util = [paths.code, filesep, 'util'];
paths.tuning = [paths.code, filesep, 'tuning_curves'];
paths.tuning_fitting = [paths.tuning, filesep, 'tuning_curve_fitting']; 
paths.cor_code = [paths.code, filesep, 'cor']; % correlation analysis code
paths.image_processing = [paths.code, filesep, 'image_processing']; 
paths.fig_funcs = [paths.code, filesep, 'fig_funcs'];
paths.downloaded = [paths.code, filesep, 'downloaded'];
paths.gaussfit = [paths.downloaded, filesep, 'gaussfit']; 

 paths_to_add =  {paths.code;...
     paths.util;...
     paths.tuning;...
     paths.tuning_fitting;...
     paths.cor_code;... 
     paths.image_processing;...
     paths.fig_funcs;...
     paths.downloaded;...
     paths.gaussfit;...
     paths.data;...
};

 addpath(paths_to_add{:});
