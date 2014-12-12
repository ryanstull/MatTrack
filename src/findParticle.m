%{

FUNCTION FINDPARTICLE, A

This function tracks a SINGLE particle in either a single picture or a
movie. If the parameter is a picture it return a 2x1 matrix

where (0) is the x coordinate, & (1) is the y coordinate, if the paramter
is a movie it will return a 2xD matrix where D

is the size of the number of frames of the movie, where (0,i) is the x
coordinate of the particle in the ith frame, & (1,i)

is the y coordinate of the particle in the ith frame.

INPUTS:

- A: The picture or the movie of the particle

OUTPUTS:

- returnM: A 2xD matrix where D is the number of frames in the movie, which
stores the x & y coordinates of the particle

NOTES:

- The program is designed to track a white particle on a black (or darker)
background, if your movie is with a black particle

you simply need to invert the movie.  You can do this by using the command
"myMovie=255b-myMovie"

- Only works if the entire particle is visible on the screen, if the
particle is partly off screen at the beginning or end of

your movie the position will not be accurate for the those frames.

- Particles cannot overlap or the program will detect them as the same
particle

MODIFICATION HISTORY

Created for IDL by Ryan Stull & Sebastian Hurtado Parra, Saint Joseph's University
06/2013

05/2014 Translated to MATLAB

08/27/2014: Added the "Highpower" section for MATLAB

09/13/2014: Added circleness and circ_rad functions which check how close to a circle 
			our particle is. They're a form of quality control, and they bound the 
			error.
			
			Also added the neighbors function which joins together regions above
			threshold that become contiguous after Highpower.
			
			NOTE: Must remove the threshRaiseCounter in order to actually have the 
			error bounded. This means that we need spherical particles, NO HATS!

%}

function [returnM] = findParticle(A,varargin)

%Declaration of functions
    function [chckBrd] = travItr(chckBrd,repNum,index)
        
        tmp=find(chckBrd == repNum);
        
        tmp=tmp(1);
        
        s2=size(chckBrd);
        
        startPointer = 1;
        endPointer = 1;
        
        toProcessArr=zeros(2,0,'int32');
        
        toProcessArr(1,1)=mod(tmp - 1, s2(1)) + 1;
        toProcessArr(2,1)=floor((tmp - 1)/s2(1)) + 1;
        endPointer=endPointer+1;
        
        while(startPointer<endPointer)
            x=toProcessArr(1,startPointer);
            y=toProcessArr(2,startPointer);
            if y-1 >= 1
                if(chckBrd(x,y-1) == repNum)
                    toProcessArr(1,endPointer)=x;
                    toProcessArr(2,endPointer)=y-1;
                    chckBrd(x,y-1)=-2;
                    endPointer=endPointer+1;
                end
            end
            if x-1 >= 1
                if chckBrd(x-1,y) == repNum
                    toProcessArr(1,endPointer)=x-1;
                    toProcessArr(2,endPointer)=y;
                    chckBrd(x-1,y)=-2;
                    endPointer=endPointer+1;
                end
            end
            if y+1 <= s2(2)
                if chckBrd(x,y+1) == repNum
                    toProcessArr(1,endPointer)=x;
                    toProcessArr(2,endPointer)=y+1;
                    chckBrd(x,y+1)=-2;
                    endPointer=endPointer+1;
                end
            end
            if x+1 <= s2(1)
                if chckBrd(x+1,y) == repNum
                    toProcessArr(1,endPointer)=x+1;
                    toProcessArr(2,endPointer)=y;
                    chckBrd(x+1,y)=-2;
                    endPointer=endPointer+1;
                end
            end
            chckBrd(x,y)=index;
            startPointer=startPointer+1;
        end
        
    end

    function [chckBrd] = fillIn(chckBrd)
        
        %This block changes all black regions to have a unique number
        m=max(max(chckBrd));
        
        %numFill is used to designate an int to each new section of black
        numFill=m+1;
        s1=size(chckBrd);
        
        while 1 == 1
            %Check to see if there is still black left
            whr=find(chckBrd == 0);
            if numel(whr) == 0
                break;
            end
            
            %posBlack=find(chckBrd == 0);
            
            %Convert next black region
            %disp(numFill)
            chckBrd=travItr(chckBrd,0,numFill);
            
            numFill=numFill+1;
        end
        
        %FillList is a list of all of the peviously black regions
        fillList=zeros(1,numFill-m,'uint32');
        
        %This loop sets to 0 all corralled regions that border the edge of
        %the image
        for w=1:numFill-m
            %{
            posBlack=find(chckBrd == (w+m));
            s2=numel(posBlack);
            for j2=1:s2
                if mod(posBlack(j2)-1,s1(1))+1 == 0 || mod(posBlack(j2)-1,s1(1))+1 == s1(1) || floor((posBlack(j2)-1)/s1(1))+1 == 0 || floor((posBlack(j2)-1)/s1(1))+1 == s1(2)
                    fillList(w)=0;
                    break
                end
                if j2 == s2
                    fillList(w)=1;
                end
            end
            %}
            [posBlackX,posBlackY]=find(chckBrd == (w+m));
            s2=size(posBlackX);
            for j2=1:s2(1)
                if posBlackX(j2)==1 || posBlackY(j2)==1 || posBlackX(j2)==s1(1) || posBlackY(j2)==s1(2)
                    fillList(w)=0;
                    break;
                end
                if j2 == s2(1)
                    fillList(w)=1;
                end
            end            
        end
        
        for w=1:numFill-m
            %{
            posBlack,posBlack=find(chckBrd == (w+m));
            posBlack=posBlack(1);
            if fillList(w) == 1
                repNum=chckBrd(mod(posBlack-1,s1(1))+1,floor((posBlack-1)/s1(1))+1);
            else
                repNum=0;
            end
            % if (w+m) ~= repNum
            chckBrd=travItr(chckBrd,w+m,repNum);
            % end
            %}
            [posX,posY] = find(chckBrd == (w+m));
            sp = size(posX);
            if fillList(w) == 1
                repNum = chckBrd(posX(1)-1,posY(1)-1);
            else
                repNum=0;
            end
            for i2=1:sp(1)
                chckBrd(posX(i2),posY(i2)) = repNum;
            end
        end
    end

    % This function attemps to find how "circular" a particle is.
    % It does so by checking the radius of the particle along
    % different directions. 
    function [distance] = circ_rad(chckBrd,y_i,x_i,direction)
        
        index = chckBrd(x_i,y_i);
        [rowSize,colSize] = size(chckBrd);
        x_num=0;
        y_num=0;
        
        while chckBrd(x_i + x_num,y_i + y_num) == index
            
            if direction == 1
                y_num = y_num + 1;
            end
            
            if direction == 2
                x_num = x_num - 1;
            end
            
            if direction == 3
                y_num = y_num - 1;
                
            end
            
            if direction == 4
                x_num = x_num + 1;
            end

            if direction == 5
                x_num = x_num + 1;
                y_num = y_num + 1;
            end
            
            if direction == 6
                x_num = x_num - 1;
                y_num = y_num - 1;
            end
            
            if direction == 7
                x_num = x_num - 1;
                y_num = y_num + 1;
            end
            
            if direction == 8
                x_num = x_num + 1;
                y_num = y_num - 1;
            end
            
            if(x_i + x_num > rowSize)
                x_num = x_num-1;
                break;
            end
            if(y_i + y_num > colSize)
                y_num = y_num-1;
                break;
            end
            if x_i + x_num < 1
                x_num=x_num+1;
                break;
            end
            if(y_i + y_num < 1)
                y_num = y_num+1;
                break;
            end
        end
        
        distance = sqrt( (x_num - 1)^2 + (y_num - 1)^2);
    end

    function [circleness] = circleness(chckBrd,y_0,x_0)
        
        %chckBrd=chckBrd.';
        dists = zeros(8,1,'double');
        RADIUS = 50;
        NORM_PERCENT = .12;
        RAD_PERCENT = .08;
        
        for i4=1:8
            dists(i4) = circ_rad(chckBrd,y_0,x_0,i4);
        end
        
        normedDev = std(dists)/RADIUS;
        
        [pixelsY,pixelsX] = find(chckBrd==chckBrd(x_0,y_0));
        
        xMaximum = max(pixelsX);
        xMinimum = min(pixelsX);
        yMaximum = max(pixelsY);
        yMinimum = min(pixelsY);
        rightDist= xMaximum - y_0;
        leftDist = y_0 - xMinimum;
        upDist = x_0 - yMinimum;
        downDist = yMaximum - x_0;
        
        if normedDev < NORM_PERCENT && abs(rightDist-dists(1))/RADIUS < RAD_PERCENT && abs(dists(3)-leftDist)/RADIUS < RAD_PERCENT && abs(upDist-dists(2))/RADIUS < RAD_PERCENT && abs(dists(4)-downDist)/RADIUS < RAD_PERCENT
           circleness = 1;
        else
           circleness = 0;
        end
    end

    function [neighbors] = neighbor(chckBrd,id_num)
        
        [row_coord,col_coord] = find(chckBrd == id_num);
        [rowSize,colSize] = size(chckBrd);
        s_rows = size(row_coord);
        neighbors = [id_num];
        
        for i1 = 1:s_rows(1)
            
            if row_coord(i1)+1 <= rowSize
                if numel(find(neighbors == chckBrd(row_coord(i1) + 1, col_coord(i1)))) == 0
                    neighbors = [neighbors; chckBrd(row_coord(i1) + 1, col_coord(i1))];
                end
            end
            if col_coord(i1)+1 <= colSize
                if numel(find(neighbors == chckBrd(row_coord(i1), col_coord(i1) + 1))) == 0
                    neighbors = [neighbors; chckBrd(row_coord(i1), col_coord(i1) + 1)];
                end
            end
            if row_coord(i1)-1 >= 1
                if numel(find(neighbors == chckBrd(row_coord(i1) - 1, col_coord(i1)))) == 0
                    neighbors = [neighbors; chckBrd(row_coord(i1) - 1, col_coord(i1))];
                end
            end
            if col_coord(i1)-1 >= 1
                if numel(find(neighbors == chckBrd(row_coord(i1), col_coord(i1) - 1))) == 0
                    neighbors = [neighbors; chckBrd(row_coord(i1), col_coord(i1) - 1)];
                end
            end
        end
        
        
    end

highPower=-1;
viewTrack=-1;

for i = 1:length(varargin)
    switch varargin{i}
        case '-highpower'
            highPower=1;
        case '-viewTrack'
            viewTrack=1;
    end
end

s = size(A);

%Initializing return Matrix & determine number of runs
if ndims(A) == 2
    runN=1;
    returnM=zeros(1, 2, 'double');
else
    runN=s(3);
    returnM=zeros(s(3), 2, 'double');
end

for dpt=1:runN
    
    disp(dpt);
    
    layer=A(:,:,dpt);
    s=size(layer);
    %Here just filter the image a lil bit
    %layer = 10*bpass(layer,3,20);
    
    %Here we add a little windowing feature, that only looks within a
    %certain area of the picture, which is determined by the position
    %of last track
    xmin = 0;
    ymin = 0;
    threshRaiseCounter=0;
    brFraction=.05;
    firsttimerun = 1;
    
    if dpt > 1
        radius = 160;
        xmin = round(returnM(dpt-1,1) - radius);
        xmax = round(returnM(dpt-1,1) + radius);
        ymin = round(returnM(dpt-1,2) - radius);
        ymax = round(returnM(dpt-1,2) + radius);
        if xmin < 1
            xmin = 1;
        end
        if ymin < 1
            ymin = 1;
        end
        if xmax > s(1)
            xmax = s(1);
        end
        if ymax > s(2)
            ymax = s(2);
        end
        
        layer = layer(xmin:xmax,ymin:ymax);
        s = size(layer);
    end
    
    
    
    maxBrt=max(max(layer));
    
    avgBrt=mean(mean(layer));
    
    diff=maxBrt-avgBrt;
    
    while (firsttimerun == 1 || circ_factor == 0) && threshRaiseCounter <= 5
    
        firsttimerun = 0;
        
        brThresh=avgBrt+diff*(brFraction);

        %spans finds the pixels in the picture that are above threshold
        %chckBrd will function as a simplified picture where white are pixels above threshold    
        %& black are pixels below threshold
        spans=find(layer > brThresh);

        chckBrd=zeros(s(1),s(2),'int32');

        SS = size(spans);

        for i=1:SS(1)
            chckBrd(mod(spans(i)-1, s(1) ) + 1,floor((spans(i) - 1)/s(1)) + 1)=-1;
        end

        k=1;


        while numel(find(chckBrd == -1)) > 0
            chckBrd=travItr(chckBrd,-1,k);
            k = k + 1;
        end

        %chckBrd=transpose(chckBrd);

        %HIGHPOWER SECTION BEWARE
        %Sometimes images of the particle will not be very clear, and shadows
        %appear within the particle (this tends to happen with brightfield
        %microscopy. The result is that portions of the particle will be
        %detected as below threshold, and the algorithm will not detect the
        %true center of the particle.
        %The idea behind the Highpower setting is to "fill in" any "empty"
        %spots within the particle that result from shadows. More specifically,
        %this function counts elements whose brightness classifies black (below
        %threshold) as white (above threshold) whenever the elements are
        %corralled by other elements that are actually white (actually above
        %threshold). Once again, in simple terms, it just 'colors in' the
        %particle.
        %THIS IS FOR THE HIGHPOWER SETTING

        if highPower ~= -1
            chckBrd = fillIn(chckBrd);
        end

        if viewTrack~=-1
            view=zeros(s(1),s(2),'single');
            for i=1:s(1)
                for j=1:s(2)
                    if chckBrd(i,j) > 0
                        view(i,j)=1;
                    end
                end
            end
            figure(1);
            imshow(view);
            figure(2);
            imshow(layer);
            pause();
        end


        pos=find(layer == maxBrt);

        pos=pos(1);

        num=chckBrd(mod(pos - 1, s(1) ) + 1 ,floor((pos - 1)/s(1)) + 1);

        nums=find(chckBrd == num);

        n=size(nums);
        
        if(dpt>=210)
            disp('');
        end
        
        neighbors_id = neighbor(chckBrd, num);
        
        for i3 = 1:numel(neighbors_id)
            if neighbors_id(i3) ~= num && neighbors_id(i3) ~= 0
                [row_pos,col_pos] = find(chckBrd == neighbors_id(i3));
                for j3 = 1:numel(row_pos)
                    chckBrd(row_pos(j3),col_pos(j3)) = num;
                end
            end
        end

        
        
        xNums=zeros(s(1), 1, 'uint32');

        yNums=zeros(s(2),1,'uint32');


        for i=1:n(1)

            yNums( floor((nums(i) - 1)/s(1)) + 1 )=yNums( floor((nums(i) - 1)/s(1)) + 1 ) + 1;

        end

        for i=1:n(1)

            xNums( mod( nums(i) - 1 , s(1) ) + 1 ) = xNums( mod( nums(i) - 1 , s(1) ) + 1 ) + 1;

        end


        avgX=0;
        avgY=0;
        xtot=0;
        ytot=0;


        for i=1:s(1)

            if xNums(i) > 0

                avgX=avgX+i*xNums(i);

                xtot=xtot+xNums(i);

            end

        end

        avgX=cast(avgX,'double')/cast(xtot,'double');


        for i=1:s(2)

            if yNums(i) > 0

                avgY=avgY+i*yNums(i);

                ytot=ytot+yNums(i);

            end

        end

        avgY=cast(avgY,'double')/cast(ytot,'double');

        circ_factor=circleness(chckBrd,floor(avgY),floor(avgX));
        brFraction = brFraction + .05;
        threshRaiseCounter=threshRaiseCounter+1;
    end
    
    
    returnM(dpt,1)=avgX+xmin;
    
    returnM(dpt,2)=avgY+ymin;
end

end
