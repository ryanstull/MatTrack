function [a] = importTiff(image)

a = imread(image);
a = mat2gray(a);
a=1-a;

end
