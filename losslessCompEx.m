%% Lossless Image Compression

I = imread('angioleiomyoma_of_the_ear_biopsy.jpg');

imcompresstypes = {'Arithmetic','Huffman','Lempel-Ziv-Welch','Run Length'};
values = length(imcompresstypes)+1;
titles = cell(1,values);
Ia = zeros(size(I));
Ih = Ia;
Ilzw = Ia;
Irl = Ia;
tmp = zeros(1,size(I,3));
lossless = zeros(1,length(imcompresstypes));
compRatio = lossless;

for i=1:length(imcompresstypes)
    for j=1:size(I,3)
        switch imcompresstypes{i}
            case 'Arithmetic'
                [Ia(:,:,j),lossless(i),tmp(j)] = arithmeticCoding(I(:,:,j));
                compRatio(i) = mean(tmp);
            case 'Huffman'
                [Ih(:,:,j),lossless(i),tmp(j)] = huffmanCoding(I(:,:,j));
                compRatio(i) = mean(tmp);
            case 'Lempel-Ziv-Welch'
                [Ilzw(:,:,j),lossless(i),tmp(j)] = lzwCoding(I(:,:,j));
                compRatio(i) = mean(tmp);
            case 'Run Length'
                [Irl(:,:,j),lossless(i),tmp(j)] = runlengthCoding(I(:,:,j));
                compRatio(i) = mean(tmp);
        end
    end
end

Icomp = uint8(cat(3,Ia,Ih,Ilzw,Irl));
tmp = 1;
for i=1:values
    if i==1
        Im = I;
        titles{i} = 'Original';
    else
        Im = Icomp(:,:,tmp:tmp+2);
        titles{i} = strcat(imcompresstypes(i-1));
        tmp = tmp+3;
    end
    subplot(1,values,i)
    imshow(Im)
    title(titles{i})
end

function [Iac,loss,compRatio] = arithmeticCoding(Im)

data = Im(:);
input = double(data);
% Determine unique symbols and their counts
[alphabet,~,seq] = unique(input);
counts = histc(input,alphabet);
% Encode the data using arithmetic coding
code = arithenco(seq,counts);
% Decode the compressed data
dseq = arithdeco(code,counts,length(input));
Iac = dseq-1;
% Reshape the decoded sequence back to an image
Iac = reshape(Iac,size(Im,1),size(Im,2));
% Verify that the decoded image matches the original
loss = isequal(Im, uint8(Iac));
compRatio = numel(data)/numel(code);
% I = imread('angioleiomyoma_of_the_ear_biopsy.jpg');
% gg = I(:,:,1);
% tt = im2col(gg,[8,8],'distinct');
% %vC = zeros(256, 1); %<! Counts
% vS = gg(:)+1; %<! The stream
% vC = histcounts(gg,256);
% vsg = double(vS);
% vCode = arithenco(double(vS), vC);
% dseq = arithdeco(vCode,vC,length(vS));
% figure
% imshow(gg)
% ss = reshape(dseq,[724,1024]);
% figure
% imshow(uint8(ss))
end

function [Ihc,loss,compRatio] = huffmanCoding(Im)

data = Im(:);
input = double(data);
[p,symbols]=hist(input,unique(input));
p = p/sum(p);
[dict,avglen] = huffmandict(symbols,p); 
code = huffmanenco(input,dict);

sig = huffmandeco(code,dict);
Ihc = reshape(sig,size(Im,1),size(Im,2));
loss = isequal(input,sig);
compRatio = numel(input)/(numel(code)+numel(dict));

end

function [Ilzw,loss,compRatio] = lzwCoding(Im)

% creating binary vector
Binary = imbinarize(Im);
% Encoding the image
Encoded = logical(LZW_img_enc(Binary')); % the transpose to ascend through the elements row by row
% calculating the compression ratio
compRatio = numel(Binary)/numel(Encoded);
% Decoding the encoded image and fitting to the original size
Ilzw = logical(vec2mat(LZW_img_dec(Encoded),numel(Binary(1,:))));
% [seq,dict] = norm2lzw(Im);
% [dseq,dict] = lzw2norm(seq);
% Ilzw = reshape(dseq,size(Im,1),size(Im,2));
loss = isequal(Binary,Ilzw);
Ilzw = double(Ilzw).*double(Im);
end

function [Irl,loss,compRatio] = runlengthCoding(Im)

data = Im(:);
input = double(data);
seq = rle(input);
dseq = irle(seq);
Irl = reshape(dseq,size(Im,1),size(Im,2));
loss = isequal(Im, uint8(Irl));
compRatio = numel(input)/numel(seq);

end