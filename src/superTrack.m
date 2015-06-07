
root = inputdlg('Select a root directory');
root = root{1};
cd(root);

files = dir;

for i=1:length(files)
    if isdir(files(i).name) && ~strcmp(files(i).name,'.') && ~strcmp(files(i).name,'..')
        cd(files(i).name);
        
        autoTrack();
        
        cd('..');
    end
end