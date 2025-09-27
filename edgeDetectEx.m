%% Edge Detection

I = imread('monarch-butterfly-flowers-bush.png');
I_gray = im2gray(I);

edgetypes = {'approxcanny','Canny','log','Prewitt','Roberts','Sobel','zerocross'};
values = length(edgetypes)+1;
titles = cell(1,values);
titles2 = cell(size(edgetypes));

Iedge = zeros(size(I_gray,1),size(I_gray,2),3*length(edgetypes));
Ilabel = zeros(size(I_gray,1),size(I_gray,2),length(edgetypes));

t = 1;
for i=1:length(edgetypes)
    Ilabel(:,:,i) = edge(I_gray,edgetypes{i});
    Iedge(:,:,t:t+2) = uint8(labeloverlay(I,Ilabel(:,:,i),"Transparency",0));
    t = t+3;
end

t = 1;
for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        Im = Iedge(:,:,t:t+2);
        titles{i} = strcat(edgetypes(i-1));
        titles2{i-1} = strcat(edgetypes(i-1));
        figure(1)
        subplot(1,values-1,i-1)
        imshow(Ilabel(:,:,i-1))
        title(titles2{i-1})
        t = t+3;
    end
    figure(2)
    subplot(1,values,i)
    imshow(uint8(Im))
    title(titles{i})
    
    
end