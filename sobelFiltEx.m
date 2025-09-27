%% Sobel Filter
% read in the image
image = '3d_ultrasound_fetus_face.jfif';
I = imread(image);

% initialize gradient direction
gdir = ['X','Y','Z'];
values = length(gdir)+1;
titles = cell(1,values);

% calculate the sobel filter with different gradient directions
for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        H = fspecial3("sobel",gdir(i-1));
        Im = imfilter(I,H,"replicate");
        titles{i} = strcat('G',lower(gdir(i-1)));
    end
    subplot(1,values,i)
    imshow(Im)
    title(titles{i})
end