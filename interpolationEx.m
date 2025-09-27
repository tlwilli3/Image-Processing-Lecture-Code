%% Image interpolation

I = imread("ascending_aortic_dissection_male.png");
[rows,cols,~] = size(I);
interpolationtypes = {"nearest","bilinear","bicubic"};

% the image enlargement on vertical and horizontal direction is 2^ZK 
ZK = 1;   
% maximum radius of the local circular window
MT = 6;    
% minimum radius of the local circular window
ML = 3;    
% brightness tollerance
BT = 16;   
% maximum brigthess difference for smooth areas
BS = 8;    
% number of image bits per layer
SZ = 8;
    
% verbose mode
%      if true prints some information during calculation
VR = true;

pvalues = zeros(1,4);

xrow = zeros(1,1231,3);
tmp = imresize(I,0.5,"box");
for i=1:length(interpolationtypes)+1    
    if i==1
        tmp2 = inedi(tmp,ZK,MT,ML,BT,BS,SZ,VR); 
        EIr = [tmp2;xrow];
        pvalues(i) = psnr(EIr,I);        
        figure
        imshow(EIr)
    else
        Iint = imresize(tmp,[rows,cols],interpolationtypes{i-1});
        pvalues(i) = psnr(Iint,I);
        figure
        imshow(Iint)
    end
end