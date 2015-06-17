function playMovie(movie,varargin)

track1=[];
track2=[];
loops=1;
startFrame=1;
delay = 0.003;
showFrame = 1;
s=size(movie);

for i = 1:2:length(varargin)
    switch varargin{i}
        case 'track1'
            track1=varargin{i+1};
        case 'track2'
            track2=varargin{i+1};
        case 'loops'
            loops=varargin{i+1};
        case 'startFrame'
            startFrame=varargin{i+1};
        case 'delay'
            delay=varargin{i+1};
        case 'showFrame'
            showFrame=varargin{i+1};
    end
end

for j=1:loops
    for i=startFrame:s(3)
        
        frame = movie(:,:,i);
        hold off;
        imshow(frame);
        hold on;
        
        if(showFrame~=-1)
            text(20,20,strcat('Frame ',num2str(i)),'Color','white');
        end
        
        if numel(track1) ~= 0
            plot(track1(i,2), track1(i,1),'*');
        end
        
        if numel(track2) ~= 0
            plot(track2(i,2), track2(i,1),'*');
        end
        
        %Good delay is 0.003
        pause(delay);
    end
end
end
