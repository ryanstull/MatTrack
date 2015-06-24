
root = inputdlg('Select a root directory');
root = root{1};
cd(root);

files = dir;

for i=1:length(files)
    if isdir(files(i).name) && ~strcmp(files(i).name,'.') && ~strcmp(files(i).name,'..')
        cd(files(i).name);
        
        num = regexp(files(i).name,'run(\d*)','tokens');
        num = num{1}; % This is not a mistake- on our part ;)
        num = num{1}; % DO NOT CHANGE!
        
        autoTrack('FPC',500,'numberRun',num);
        
        cd('..');
    end
end