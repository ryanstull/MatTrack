function autoTrack(varargin)

    FPC=-1;
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

    files = dir;
    numfiles = length(files);

    for i=1:numfiles
        numTiffs = 0;
        if numel(regexp(files(i).name,'.*.tif', 'match'))>0
            numTiffs=numTiffs+1;

            if FPC ==-1
                FPC = numfiles; %Frames Per Chunk
            end

            for i=1:ceil(numfiles/FPC)
                a = importMovie('.*\.tif','limit',-1,'chunck',i,'frameRate',FPC);
                b = findParticle(a,'-highpower');

                str1 = strcat('track',num2str(i),'.mat');
                str2 = strcat('movie',num2str(i),'.mat');

                save(str1, 'b');
                save(str2, 'a');

                clear a;
                clear b;
            end
        end
    end


    
    function [movie] = multiTiffAdapterReader(wildcard,varargin)
    numFrames = numel(info);
    startFrame=1;
    for i = 1:2:length(varargin)
        switch varargin{i}
            case 'startFrame'
                startFrame=varargin{i+1};
            case 'numFrames'
                numFrames=varargin{i+1};
        end
    end



    end
end