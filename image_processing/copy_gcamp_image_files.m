%%%% copy image files into a new directory so that they can be copied onto
%%%% another computer
%
% original folders on F drive; make copies in new_top_dir

%%%% list of image files to copy
filelist_filename = 'F:\analysis_master.xlsx'; 
new_top_dir = 'G:\gcamp_image_files_copy\';

filelist = readtable(filelist_filename);
filelist = filelist(filelist.analyze_plane==1,:); % keep only image files for planes which were analyzed

for ifile = 1:height(filelist)
    newdir = strrep(filelist.directory{ifile},'F:\',new_top_dir);
    mkdir(newdir)
    regstruct = load(filelist.reg_to_patches_file{ifile});
    movingImFile = [fileparts(filelist.directory{ifile}) filesep regstruct.movingimageFile];

    copyfile([filelist.reg_to_patches_file{ifile} '.mat'], [strrep(filelist.reg_to_patches_file{ifile},'F:\',new_top_dir) '.mat']);
    copyfile([filelist.patch_file{ifile} '.mat'], [strrep(filelist.patch_file{ifile},'F:\',new_top_dir) '.mat']);    
    copyfile(movingImFile, strrep(movingImFile,'F:\',new_top_dir));
end