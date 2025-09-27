%% Contrast Enhancement - local
% read in the image
addpath(genpath(pwd))
image = 'Heart-Tissue-Slides-Hypertension-Hematoxylin-&-Eosin-Stain-NBP2-77723-img0001.jpg';
I = imread(image);
I = im2double(im2gray(I)); 
loctypes = {'CLAHE','AHE','Unsharp Masking','Retinex Theory', ...
    'Piecewise Linear Contrast Stretching'};
values = length(loctypes)+1;

avg = mean2(I);
sigma = std2(I);

% local methods

invec = linspace(0,1,100); % for creating line plot
% k is [alpha beta gamma]
% but calling things gamma is only going to create confusion
% this vector can be variable-length
% breakpoints will be spaced uniformly on x
k = [0.5 1 0.5];
% process things
outvec = kcurves(invec,k);
outpict = kcurves(I,k);

Ichahe = adapthisteq(I);
Iahe = adapthisteq(I,"ClipLimit",1);
Ium = imsharpen(I*255);
Irt = MSRetinex(I,5,3,2,[5 5],8);
Iplcs = im2uint8(outpict);
Ilcal = cat(3,Ichahe*255,Iahe*255,Ium,Irt,Iplcs);

for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        Im = Ilcal(:,:,i-1);
        titles{i} = strcat(loctypes(i-1));
    end
    subplot(1,values,i)
    imshow(Im)
    title(titles{i})
end