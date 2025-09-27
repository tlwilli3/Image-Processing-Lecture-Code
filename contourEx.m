%% Contours

I = imread("Different-amoebas-on-abstract-background.jpg");
I_gray = im2gray(I);
I_BW = imbinarize(I_gray);

% [I_ms,h_ms] = contour(I_gray);
% figure
% imshow(I_ms)
% 
figure
imcontour(I_gray)
axis off

figure
imcontour(I_BW)
axis off

mask = zeros(size(I_gray));
mask(10:end-10,10:end-10) = 1;
bw = activecontour(I_gray,mask,7000);

figure
imshow(bw)

[pixel,Ct]=contour_trace(I_BW,367,625);
figure
imshow(Ct)


% C1 = contour_following(I_BW);
% figure, imshow(I_BW)
% figure, plot(C1(:,1),C1(:,2),'*');
% axis off
% for j=1:size(C1,1)
%     text(C1(j,1),C1(j,2),['  ' num2str(j)]);
% end