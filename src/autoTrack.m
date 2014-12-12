function autoTrack(varargin)

% FPC=-1;
autoTime=-1;
time='';
for i = 1:2:length(varargin)
    switch varargin{i}
        case 'FPC'
            FPC=varargin{i+1};
        case 'autoTime'
            autoTime=varargin{i+1};
        case 'time'
            time=varargin{i+1};
    end
end

curDir = cd;
fileName = regexp(curDir,'/([^/]*)$','tokens');
fileName = fileName{1}{1};
% 
% disp(fileName);
% 
% files = dir('*.tif');
% numfiles = length(files);
% if FPC ==-1
%     FPC = numfiles; %Frames Per Chunk
% end

% for i=1:ceil(numfiles/FPC)
%     a = importMovie('.*\.tif','limit',-1,'chunck',i,'frameRate',FPC);
%     b = findParticle(a,'-highpower');
%     
%     str1 = strcat('track',num2str(i),'.mat');
%     str2 = strcat('movie',num2str(i),'.mat');
%     
%     save(str1, 'b');
%     save(str2, 'a');
%     
%     clear a;
%     clear b;
% end

stitchTrack(fileName);
if autoTime==1
    time = fileread('info.txt');
end


if autoTime==1 || numel(time) ~= 0
    timeEx ='(\d)+m ((\d+,)*\d+(\.\d*)?)s';
    res = regexp(time,timeEx,'tokens');
    minutes = str2double(res{1}{1});
    seconds = str2double(res{1}{2});
    addTime(minutes,seconds,length(dir('*.tif')),strcat(fileName,'.mat'),strcat(fileName,'.txt'));
end

end