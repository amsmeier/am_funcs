%%%% purpose of this script is to check how many pairs were assigned having 'nan' responsivity (cortable.rspv_pval)
% ...... and might have been incorrectly excluded from analysis, because they were not significant for sf/tf/orient


include_temp = all(cortable.sf_sgnf | cortable.tf_sgnf | cortable.orient_sgnf,2); 
nanpairs = all(isnan(cortable.rspv_pval),2); 
pairs_not_already_included = ~include_temp; 
potentially_excluded_by_rspv_nan = pairs_not_already_included & nanpairs; 
mean(potentially_excluded_by_rspv_nan)