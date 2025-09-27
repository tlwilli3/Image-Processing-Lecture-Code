%% Digital halftoning

I = imread("2022-05-03-jaz-muna-johns-med-student-vcu-0128.jpg");
halftonetypes = {'Random','Ordered','Floyd','Jarvis','Rylander','Stochastic'};
values = length(halftonetypes)+1;
titles = cell(1,values);
I = im2double(I);
[rows,cols,chan] = size(I);
mat = 16;
c = 16;
levels = 16;
dotSize = 0.001; % Size of the dots (in pixels)
freq = 5000; % Frequency of the FM modulation (adjust for different halftone patterns)
amp = 10000; % Amplitude of the FM modulation (adjust for different halftone patterns)

Iord = zeros(size(I));
Irand = zeros(size(I));
Ifloyd = zeros(size(I));
IJarvis = zeros(size(I));
IRylander = imresize(imresize(zeros(rows,cols,chan),0.25),4);
Ifm = zeros(size(I));

for i=1:3
    tmp = floor( (c-1)*I(:,:,i)+0.5 )/(c-1);
    Irand(:,:,i) = tmp;
    Iord(:,:,i) = orderdith(I(:,:,i),mat,c);
    Ifloyd(:,:,i) = floyddiff(I(:,:,i),2);
    IJarvis(:,:,i) = jarvisHalftone(I(:,:,i),256);
    IRylander(:,:,i) = rylander(I(:,:,i),levels);
    Ifm(:,:,i) = fmhalftone(I(:,:,i),dotSize,freq,amp);
end
IRylander = imresize(IRylander,[rows,cols]);
Ihalf = cat(3,Irand,Iord,Ifloyd,IJarvis,IRylander,Ifm);

for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        Im = Ihalf(:,:,i-1);
        titles{i} = strcat(halftonetypes(i-1));
    end
    subplot(1,values,i)
    imshow(Im)
    title(titles{i})
end

function Io = orderdith(I,mat,c)
[row,cols] = size(I);

M1 = [0,2;3,1]/4;
M2 = [M1,M1+2/16;M1+3/16,M1+1/16];
M3 = [M2,M2+2/64;M2+3/64,M2+1/64];
M4 = [M3,M3+2/256;M3+3/256,M3+1/256];
M5 = [M4,M4+2/1024;M4+3/1024,M4+1/1024];

% only using M = M2 (4x4) and M = M4 (16x16)
if mat==4
    M = M2;
elseif mat==16
    M = M4;
end

Nsub = floor(row/size(M,1)) +1;
Ncol = floor(cols/size(M,2)) + 1;
DT = repmat(M, 1, Ncol);
DT = repmat(DT, Nsub, 1);
DT = DT(1:row,1:cols);
% DT = full size dithering matrix

Io = floor( (c-1)*I+DT)/(c-1);

end

function A = floyddiff(I,c)
[row,cols] = size(I);
A = (c-1)*I;
for y = 1:cols
    for x = 1:row
        oldpixel = A(x,y);
        newpixel = round(oldpixel);
        A(x,y) = newpixel;
        quant_error = oldpixel - newpixel;
        if x<row
            A(x + 1,y)= A(x + 1,y) + quant_error * 7 / 16;
        end
        if ( x>1 ) && ( y<cols )
            A(x - 1,y + 1) = A(x - 1,y + 1) + quant_error * 3 / 16;
        end
        if y<cols
            A(x ,y + 1) = A(x ,y + 1) + quant_error * 5 / 16;
        end
        if ( x<row ) && ( y<cols )
            A(x + 1,y + 1) = A(x + 1,y + 1) + quant_error * 1 / 16;
        end
    end
end
end

function Iry = rylander(I,levels)
I = imresize(I,0.25);
[rw,cl,~] = size(I);
thresh = multithresh(I,levels);
Iq = imquantize(I,thresh);
patmap = ones(4,4,levels+1);
Iry = zeros(rw*4,cl*4);

patindx = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
           1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
           1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0;
           1 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0;
           1 0 1 0 0 0 0 0 1 0 1 0 0 0 0 0;
           1 1 1 0 0 0 0 0 1 0 1 0 0 0 0 0;
           1 1 1 0 0 0 0 0 1 0 1 1 0 0 0 0;
           1 1 1 0 0 0 0 0 1 1 1 1 0 0 0 0;
           1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0;
           1 1 1 1 1 0 0 0 1 1 1 1 0 0 0 0;
           1 1 1 1 1 0 0 0 1 1 1 1 0 0 1 0;
           1 1 1 1 1 0 0 0 1 1 1 1 1 0 1 0;
           1 1 1 1 1 0 1 0 1 1 1 1 1 0 1 0;
           1 1 1 1 1 1 1 0 1 1 1 1 1 0 1 0;
           1 1 1 1 1 1 1 0 1 1 1 1 1 0 1 1;
           1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1;
           1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;];

for i=1:size(patmap,3)
    if i == 1
        patmap(:,:,i) = patmap(:,:,1);
    else
        idx = find(patindx(i,:));
        tmp = patmap(:,:,i);
        tmp(idx) = 0;
        patmap(:,:,i) = tmp;
    end
end

t=0; u=0;
for i=1:rw
    for j=1:cl
        Iry(i+u:i+3+u,j+t:j+3+t) = patmap(:,:,Iq(i,j));
        t = t+3;
        if j==cl
            t=0;
        end
    end
    u = u+3;
end


end

function Ifm = fmhalftone(I,dotSize,freq,amp)

% Define parameters for FM halftoning
% dotSize = 1; % Size of the dots (in pixels)
% freq = 0.5; % Frequency of the FM modulation (adjust for different halftone patterns)
% amp = 0.5; % Amplitude of the FM modulation (adjust for different halftone patterns)

% Calculate the size of the halftoned image
[rows, cols] = size(I);
Ifm = zeros(rows, cols);

% Apply FM halftoning
for i = 1:rows
    for j = 1:cols
        % Calculate the FM modulated tone based on the image pixel value
        tone = I(i, j) * amp;
        
        % Calculate the frequency based on the FM modulated tone
        modulatedFreq = freq + tone;
        
        % Create a halftone dot based on the modulated frequency
        if mod(i + modulatedFreq * (j * dotSize), 1) < dotSize
            Ifm(i, j) = 1;
        else
            Ifm(i, j) = 0;
        end
    end
end

end