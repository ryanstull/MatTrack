startNum = 11;
endNum = 52;


cd('/home/ryan/Sync/School/Summer Scholars/Year 2/Data/tiff files/DMLT')
times = zeros(endNum-startNum,1);

fileName = 'times.txt';
inputfile = fopen(fileName);

for i=startNum:endNum
    if i==27||i==41
        continue;
    end
    
    disp(strcat('<<<',num2str(i),'>>>'));
    if i<10
        runNum = strcat('0',num2str(i));
        else
        runNum = num2str(i);
    end
    
    
    tline = fgetl(inputfile);
    if ~ischar(tline)
        break
    end
    
    cd(strcat('./DMLT_run0',runNum));
    autoTrack('FPC',750,'time',tline);
    txtFiles = dir('*.txt');
    for j=1:length(txtFiles)
        if ~strcmp(txtFiles(j).name,'info.txt')
            movefile(txtFiles(j).name,'..');
        end
    end
    cd('..');
end
fclose(inputfile); 