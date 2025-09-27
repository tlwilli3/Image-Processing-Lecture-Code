%% Gaussian Filtering
% read in the image
image = 'unborn-twins-MRI.png';
I = imread(image);

% initialize the filter sizes and titles
filt = [3,7,11];
sig = [1,3,5];
values = length(filt)+1;
titles = cell(1,values);
subtitle = cell(1,values);

% calculate the gaussian filter for each neighborhood and plot the images
for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        Im = imgaussfilt(I,sig(i-1),'FilterSize',filt(i-1));
        numtxt = num2str(filt(i-1));
        sigtxt = num2str(sig(i-1));
        titles{i} = strcat(numtxt,'x',numtxt);
        subtitle{i} = strcat('\sigma =',sigtxt);
    end
    subplot(1,values,i)
    imshow(Im)
    title({titles{i},subtitle{i}})
end