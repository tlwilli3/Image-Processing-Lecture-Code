%% Contrast Enhancement - Global
% read in the image
image = 'scarlet-oak-tree-1-340x453.jpg';
I = imread(image);
I = im2double(im2gray(I)); 
globtypes = {'Histogram Equalization','Min-Max Stretching', ...
    'Gamma Correction','Logarithmic Transformation','Mean & STD Stretching'};
values = length(globtypes)+1;
c = 2; % Constant
n = 1.5;  

avg = mean2(I);
sigma = std2(I);

% Global methods
Ihe = histeq(I);
Imm = imadjust(I,stretchlim(I),[]);
Ig = imadjust(I,[],[],0.5);
Il = c*log(1 + (I)); % Log Transform
Ims = imadjust(I,[avg-n*sigma avg+n*sigma],[]);
Igl = cat(3,Ihe,Imm,Ig,Il,Ims);

for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        Im = Igl(:,:,i-1);
        titles{i} = strcat(globtypes(i-1));
    end
    subplot(1,values,i)
    imshow(Im)
    title(titles{i})
end