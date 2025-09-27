%% Image segmentation - computer vision

% Read the image
I = imread('synpic20003.jpg');
% Convert to grayscale if it's a color image
if size(I, 3) == 3
    I_gray = rgb2gray(I);
else
    I_gray = I;
end

segcompvisiontypes = {'Adaptive','Cluster','Edge','Region Growing',};
values = length(segcompvisiontypes)+1;
titles = cell(1,values);

% Perform adaptive thresholding
% 'adaptive' method uses local mean or median
% 'Sensitivity' controls the sensitivity to local variations (0-1)
BW_adaptive = imbinarize(I_gray, 'adaptive', 'ForegroundPolarity', 'bright', 'Sensitivity', 0.5); 
% [P,BW_region] = regionGrowing(I_gray,[350,150],25);

% Edge-based segmentation
BW_edge = edge(I_gray, 'Canny',[0.1,0.4]); % Using Canny method
BW_filled = imfill(BW_edge, 'holes');

lab_I = rgb2lab(I);
ab = lab_I(:,:,2:3); % Extract a* and b* channels for clustering
ab = im2single(ab); % Convert to single precision for imsegkmeans
nColors = 3; % Desired number of segments/clusters
L = imsegkmeans(ab, nColors, 'NumAttempts', 3); % 'NumAttempts' helps avoid local minima

O_adaptive = labeloverlay(I,BW_adaptive);
O_clust = labeloverlay(I,L); % Overlay labels on original image
O_edge = labeloverlay(I,BW_filled);
[O_region,num_reg] = regrow(I);

Isegcv = cat(3,O_adaptive,O_clust,O_edge,O_region);

tmp = 1;
for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        Im = Isegcv(:,:,tmp:tmp+2);
        titles{i} = strcat(segcompvisiontypes(i-1));
        tmp = tmp+3;
    end
    subplot(1,values,i)
    imshow(Im)
    title(titles{i})
end

function [O_region,nr] = regrow(I)
f1 = im2gray(I);
f=double(f1);
s=255;
t=65;
if numel(s)==1
    si=f==s;
    s1=s;
else
    si=bwmorph(s,'shrink',Inf);
    j=find(si);
    s1=f(j);
end
ti=false(size(f));
for k=1:length(s1)
    sv=s1(k);
    s=abs(f-sv)<=t;
    ti=ti|s;
end
[g,nr]=bwlabel(imreconstruct(si,ti));
O_region = labeloverlay(I,g);
end
