% read in the image
image = 'Brain-MRI-Scan.png';
I = imread(image);

% initialize the filter sizes and titles
filt = [3,7,11];
values = length(filt)+1;
titles = cell(1,values);

% calculate the mean filter for each neighborhood and plot the images
for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        Im = imboxfilt(I,filt(i-1));
        numtxt = num2str(filt(i-1));
        titles{i} = strcat(numtxt,'x',numtxt);
    end
    subplot(1,values,i)
    imshow(Im)
    title(titles{i})
end