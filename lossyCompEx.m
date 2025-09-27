%% Lossy Image Compression

I = imread("synpic15358.jpg");

[rows,cols,chan] = size(I);
lossycompresstypes = {'Discrete Cosine Transform', 'Discrete Fourier Transform', 'Discrete Wavelet Transform', 'Fractal Compression'};

values = length(lossycompresstypes)+1;
Idct = zeros(size(I));
Idwt = Idct;
Idft = Idct;
Ifc = imresize(imread("synpic15358_fractal.png"),[rows,cols]);
tmp = zeros(1,chan);
lossless = zeros(1,length(lossycompresstypes));
compRatio = lossless;

for i=1:length(lossycompresstypes)
    for j=1:chan
        switch lossycompresstypes{i}
            case 'Discrete Cosine Transform'
                [Idct(:,:,j),lossless(i),tmp(j)] = dctCompression(I(:,:,j),8,4);
                compRatio(i) = mean(tmp);
            case 'Discrete Fourier Transform'
                [Idft(:,:,j),lossless(i),tmp(j)] = dftCompression(I(:,:,j),0.0005);
                compRatio(i) = mean(tmp);
            case 'Discrete Wavelet Transform'
                [Idwt(:,:,j),lossless(i),tmp(j)] = dwtCompression(I(:,:,j),'haar',0.7,'1001');
                compRatio(i) = mean(tmp);
            case 'Fractal Compression'
                lossless(i) = 0;
                compRatio(i) = 2.7520;
        end
    end
end

Ilossy = uint8(cat(3,Idct,Idft,Idwt,Ifc));
tmp = 1;
for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        Im = Ilossy(:,:,tmp:tmp+2);
        titles{i} = strcat(lossycompresstypes(i-1));
        tmp = tmp+3;
    end
    subplot(1,values,i)
    imshow(Im)
    title(titles{i})
end

function [Idwt,loss,compRatio] = dwtCompression(Im,type,thresh,subbands)

[rows,cols] = size(Im);

[cA,cH,cV,cD] = dwt2(Im,type);
cN = cat(3,cA,cH,cV,cD);
cTh = zeros(size(cA,1),size(cA,2),3);

for i=1:length(subbands)-1
    cTh(:,:,i) = wthresh(cN(:,:,i+1),'s',thresh);
end

switch subbands
    case '1111'
        Idwt = idwt2(cA,cTh(:,:,1),cTh(:,:,2),cTh(:,:,3),type);
    case '1110'
        Idwt = idwt2(cA,cTh(:,:,1),cTh(:,:,2),[],type);
    case '1101'
        Idwt = idwt2(cA,cTh(:,:,1),[],cTh(:,:,3),type);
    case '1011'
        Idwt = idwt2(cA,[],cTh(:,:,2),cTh(:,:,3),type);
    case '0111'
        Idwt = idwt2([],cTh(:,:,1),cTh(:,:,2),cTh(:,:,3),type);
    case '0011'
        Idwt = idwt2([],[],cTh(:,:,2),cTh(:,:,3),type);
    case '0101'
        Idwt = idwt2([],cTh(:,:,1),[],cTh(:,:,3),type);
    case '0110'
        Idwt = idwt2([],cTh(:,:,1),cTh(:,:,2),[],type);
    case '1010'
        Idwt = idwt2(cA,[],cTh(:,:,2),[],type);
    case '1001'
        Idwt = idwt2(cA,[],[],cTh(:,:,3),type);
    case '1100'
        Idwt = idwt2(cA,cTh(:,:,1),[],[],type);
    case '0001'
        Idwt = idwt2([],[],[],cTh(:,:,3),type);
    case '0010'
        Idwt = idwt2([],[],cTh(:,:,2),[],type);
    case '0100'
        Idwt = idwt2([],cTh(:,:,1),[],[],type);
    case '1000'
        Idwt = idwt2(cA,[],[],[],type);
    case '0000'
        Idwt = idwt2([],[],[],[],type);
end

[rows_c,cols_c] = size(Idwt);

if ~isequal(rows,rows_c) | ~isequal(cols,cols_c)
    Idwt = imresize(Idwt,[rows,cols]);
end

compRatio = numel(Im)/(numel(cA)*nnz(str2num(subbands')));
loss = isequal(Idwt,Im);

end

function [Idct,loss,compRatio] = dctCompression(Im,blockSize,quant)

[rows,cols] = size(Im);

row_pad = mod(rows,blockSize);
col_pad = mod(cols,blockSize);

if row_pad ~= 0
    Im = padarray(Im, [blockSize-row_pad, 0], 'post');
end
if col_pad ~= 0
    Im = padarray(Im, [0, blockSize-col_pad], 'post');
end

[rows_p,cols_p] = size(Im);

compressed = zeros(rows_p,cols_p);

for i=1:blockSize:rows_p
    for j=1:blockSize:cols_p
        block = Im(i:i+blockSize-1,j:j+blockSize-1);
        dct_b = dct2(block);

        dct_b(quant:blockSize,:) = 0;
        dct_b(:,quant:blockSize) = 0;

        compressed(i:i+blockSize-1,j:j+blockSize-1) = dct_b;
    end
end

Idct = zeros(rows_p,cols_p);

for i=1:blockSize:rows_p
    for j=1:blockSize:cols_p
        block = compressed(i:i+blockSize-1,j:j+blockSize-1);
        idct_b = idct2(block);

        Idct(i:i+blockSize-1,j:j+blockSize-1) = idct_b;
    end
end
if row_pad ~= 0
    Idct = Idct(1:end-(blockSize-row_pad),:);
end
if col_pad ~= 0
    Idct = Idct(:,1:end-(blockSize-col_pad));
end

loss = isequal(Im,Idct);
compRatio = numel(Im)/nnz(compressed);

end

function [Idft,loss,compRatio] = dftCompression(Im,keep)

Ift = fft2(double(Im));

thresh = keep*max(abs(Ift(:)));
Ift_comp = Ift .* (abs(Ift) > thresh);
Idft = uint8(real(ifft2(Ift_comp)));
loss = isequal(Im,Idft);
compRatio = numel(Im)/nnz(Ift_comp);

end
