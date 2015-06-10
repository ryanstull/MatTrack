function [movie] = loadTiffStack(fname,varargin)

    info = imfinfo(fname);
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

    
    width = info.Width;
    height = info.Height;
    
    movie = zeros(height,width,numFrames,'uint16');
    for k = startFrame:startFrame+numFrames-1
        movie(:,:,k-startFrame+1) = imread(fname, k, 'Info', info);
        disp(strcat('Frame: ',num2str(k)));
    end
    
    movie = mat2gray(movie);
    movie = 1-movie;
    movie = movie(:,2:width-1,:);
end