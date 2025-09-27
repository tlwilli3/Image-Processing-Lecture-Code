function labelImage = createVoronoi(centroids,imageFilename)
% Creates 3-D voronoi image given a centroid list
% and extracts each Voronoi cell from the original image
% Input:
%   centroids - N x 3 matrix
%   imageFilename - filename of image stack
% %Set up - testing code
% centroids = load('Centroids.txt');
% imageFilename='image.tif';
if nargin == 0 % demo data
    a = 1;
    b = 100;
    x = (b-a).*rand(1000,1) + a;
    y = (b-a).*rand(1000,1) + a;
    z = (b-a).*rand(1000,1) + a;
    centroids = [x,y,z];
end
% For 2D implementation, set z column to 1
if size(centroids,2) == 2
    centroids = [centroids,ones(size(centroids,1))];
end
% Load image
if nargin < 2
    intensityImage = zeros(ceil(max(centroids))+10);
else
    InfoImage=imfinfo(imageFilename);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    intensityImage=zeros(nImage,mImage,NumberImages,'uint8');
    for i=1:NumberImages
       intensityImage(:,:,i)=imread(imageFilename,'Index',i,'Info',InfoImage);
    end
end
%% Label Image
% check if label (voronoi) image already exist else create label image
labelFilename = 'labelImage.tif';
if exist(labelFilename,'file') == 2
    disp('Loading existing label image...')
    InfoImage=imfinfo(labelFilename);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    labelImage=zeros(nImage,mImage,NumberImages,'uint8');
    for i=1:NumberImages
       labelImage(:,:,i)=imread(labelFilename,'Index',i,'Info',InfoImage);
    end
else
    labelImage = zeros(size(intensityImage));
    %find closest centroid for each voxel
    for i = 1:size(intensityImage,1)
        for j = 1:size(intensityImage,2)
            for k = 1:size(intensityImage,3)
%                 cur_idx = [i j k];
                eucDistance = sqrt((centroids(:,1)-i).^2+(centroids(:,2)-j).^2+(centroids(:,3)-k).^2);
                [~,index] = min(eucDistance);
                labelImage(i,j,k)=uint8(index);
            end
        end
    end
    for k = 1:size(intensityImage,3)
        imwrite(uint8(labelImage(:,:,k)),labelFilename,'WriteMode','append','Compression','none');
    end
    disp('Voronoi image Saved')
end
% Uncomment if you want the individual cropped labels
% %% Extract each Voronoi cell 
for cell_num = 1:size(centroids,1)
    [x,y,z] = ind2sub(size(labelImage),find(labelImage == cell_num));
    min_x = min(x);    max_x = max(x);
    min_y = min(y);    max_y = max(y);
    min_z = min(z);    max_z = max(z);

    cropImage = intensityImage(min_x:max_x,min_y:max_y,min_z:max_z);

    cellFilename = ['cropImage_',num2str(cell_num),'.tif'];
    for k = 1:size(cropImage,3)
        imwrite(uint8(cropImage(:,:,k)),cellFilename,'tif','WriteMode','append','Compression','none');
    end
    disp([cellFilename,' saved'])
end
disp('Extraction done')