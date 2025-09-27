%% 2D data types

Bch = imread('Whale-Breach-Maui-Sunset-Wailea.jpg');
Bch_gray = rgb2gray(Bch);
Bch_BW = imbinarize(Bch_gray);
inprof = iccread(profiles{14,1}.Filename);
outprof = iccread('USWebCoatedSWOP.icc');
Cim = makecform("icc",inprof,outprof);
I_cmyk = applycform(Bch,Cim);
imwrite(I_cmyk,"Whale-Breach-Maui-Sunset-Wailea.tif","tif")

figure; subplot(2,2,1), imshow(Bch); title('RGB')
subplot(2,2,2), imshow(Bch_gray); title('Gray')
subplot(2,2,3), imshow(Bch_BW); title('Binary')
subplot(2,2,4), imshow(zeros(size(Bch_gray))); title('CMYK')