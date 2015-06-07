function [movieO] = importMovie(wildcard,varargin)

limit = -1;
chunk = -1;
frameRate = -1;

for i = 1:2:length(varargin)
    switch varargin{i}
        case 'limit'
            limit=varargin{i+1};
        case 'chunck'
            chunk=varargin{i+1};
        case 'frameRate'
            frameRate=varargin{i+1};
    end
end

list = dir('*.tif');
lenlist = length(list);

%ADDITION: Purpose of sublist is to be able to import only a certain
%number of frames at a time, determined by frameRate (which defaults to 500)
if chunk==-1
    sublist = list;
else
    if frameRate==-1
        frameRate=500;
    end
    start = (chunk-1)*frameRate + 1;
    finish = start + frameRate - 1;
    %This is just to make sure we don't index past the end of list
    if finish > lenlist(1)
        finish = lenlist(1);
    end
    sublist = list(start:finish);
    for i=1:length(sublist)
        disp(sublist(i));
    end
end
%Now replace everything that said list with sublist
ls=size(sublist);
k = 0;
s = 0;

for i=1:ls(1)
    disp(i);
    if numel(regexp(sublist(i).name,wildcard, 'match'))>0
        k = k + 1;
        if(k>=limit && limit~=-1)
            break;
        end
        if k == 1
            Initmovie = importTiff(sublist(i).name);
            s=size(Initmovie);
            if limit == -1
                movieO= zeros(s(1),s(2),ls(1)-i,'single');
            else
                movieO =zeros(s(1),s(2),limit,'single');
            end
        end
        movieO(:,:,k)=importTiff(sublist(i).name);
    else
        disp(sublist(i).name);
    end
end
movieO = movieO(:,2:s(2),:);
end
