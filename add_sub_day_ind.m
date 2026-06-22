 %%% add subject-relative day index to filetable and roitable
 % call this function from tuning_stats.m 
 
 unq_subs = unique(filetable.sub);
 nsubs = length(unq_subs);
 nfiles = height(filetable);
 filetable.sub_day_ind = nan(nfiles,1);

 
 for isub = 1:nsubs
     % add to filetable 
     thissub = unq_subs(isub);
     filetable_rowmatch = filetable.sub == thissub;
     [unq_days_this_sub, ~, filetable.sub_day_ind(filetable_rowmatch)] = unique(filetable.day(filetable_rowmatch));
     n_days_this_sub = length(unq_days_this_sub); 
     
     % add to roitable
     for iday = 1:n_days_this_sub
         roi_rowmatch = filetable.sub==thissub & filetable.sub_day_ind == iday;
         thisday = filetable.day{roi_rowmatch};
         roitable_rowmatch = roitable.day == string(thisday); 
         roitable.sub_day_ind(roitable_rowmatch) = iday;
     end
     
 end
     
 filetable = movevars(filetable,'sub_day_ind','Before','day');
  roitable = movevars(roitable,'sub_day_ind','Before','day');