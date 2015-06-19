function autoTrack(varargin)

    FPC=0;
    autoTime=0;
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

    tiffs = getTiffsInThisDir();
    
    numTiffs = length(tiffs);
    framesPerTiff = zeros(1,length(tiffs));
    sumOfFrames = zeros(1,length(numTiffs));

    for i=1:numTiffs
        info = imfinfo(tiffs(i).name);
        framesPerTiff(i) = numel(info);
        if i==1
            sumOfFrames(i) = framesPerTiff(i);
        else
            sumOfFrames(i) = framesPerTiff(i) + sumOfFrames(i-1);
        end
    end
    
    if FPC==0
        movie = multiTiffAdapter();
        track = findParticle(a,'-highpower');
        
        save('track.mat','track');
        save('movie.mat','movie');
    else
        for i=1:ceil(sumOfFrames(length(sumOfFrames))/FPC)
            movie = multiTiffAdapter();
            track = findParticle(movie,'-highpower');
            
            save(strcat('track',num2str(i),'.mat'),'track');
            save(strcat('movie',num2str(i),'.mat'),'movie');
            
            clear movie;
            clear track;
        end
    end
    
    stitchTrack();

    function [movie] = multiTiffAdapter()
        if FPC==0
            movie = [];
            for j=1:numTiffs
                movie = cat(movie,loadTiffStack(tiffs(j).name),3);
            end
        else
            slice(1) = FPC*(i-1)+1;
            slice(2) = FPC*i;
            where(1) = whoContainsRange(1);
            where(2) = whoContainsRange(2);
            
            if where(2) == -1
                slice(2) = sumOfFrames(length(sumOfFrames));
                where(2) = where(1);
            end

            if where(1)==where(2)
                slice(1)=correctRange(1);
                slice(2)=correctRange(2);
                movie = loadTiffStack(tiffs(where(1)).name,'startFrame',slice(1),'numFrames',slice(2)-slice(1)+1);
            else
                movie = loadTiffStack(tiffs(where(1)).name,'startFrame',slice(1),'numFrames',framesPerTiff(where(1))-slice(1)+1);
                movie = cat(3,movie,loadTiffStack(tiffs(where(2)).name,'startFrame',1,'numFrames',slice(2)-sumOfFrames(where(1))));
            end
        end
        
        function [corrected] = correctRange(AorB)
            if(where(AorB)==1)
                corrected = slice(AorB);
            else
                corrected = slice(AorB) - sumOfFrames(where(1)-1);
            end
        end
        
        function [whoContains] = whoContainsRange(AorB)
            for k=1:numTiffs
                if slice(AorB)<sumOfFrames(k)
                    whoContains = k;
                    return;
                end
            end
            whoContains = -1;
        end
    end

    function [files] = getTiffsInThisDir()
        files = dir;
        for index=length(files):-1:1
            if numel(regexp(files(index).name,'.*.tif', 'match'))==0
                files(index) = [];
            end
        end
    end

    function stitchTrack()

        list = dir('.');
        ls = size(list);

        trackArr = zeros(0,2);

        for m=1:ls(1)
            if numel(regexp(list(m).name,'track.*\.mat')) > 0
            disp(list(m).name);

            load(list(m).name);
            trackArr = cat(1,trackArr,track);
            clear track;
            end
        end

        save('finalTrack.mat','trackArr');

    end
end
