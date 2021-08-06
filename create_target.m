%% load images
clear;
dir='Datasets\Real_datasets\oeste_2';
imds = imageDatastore(dir);

% select images (only the selected samples
images = cell(1, numel(imds.Files));
color_images= cell(1, numel(imds.Files));
for i=1:numel(imds.Files)
    I = readimage(imds, i);
    images{i} = rgb2gray(I);
    color_images{i}=I;
end
%% insert target name and real gps
target_name='fogo';
target_gps=[ 41.310040, -7.225683,521];
%% get the pixel coordinates for the target for each image
N=numel(imds.Files);
px=zeros(N,2);
for i=1:N
    close all;
    figure;title(int2str(i));
    imshow(color_images{i}); hold on;
    px(i,:)=ginput(1);
    title(int2str(i));
end
close all;
%% or just for the first image
figure;
imshow(color_images{1}); hold on;
px=ginput(1);
%% save target data in a .mat
save(strcat(dir,'/target_5'),'target_name','target_gps','px');