function [images,color_images,samples] = initSFM(dataset,t0,step,tf)
%initSFM 

% load all dataset images
imageDir=strcat('Datasets/',dataset);
imds = imageDatastore(imageDir);

% select samples
samples=t0+1:step:tf+1;

% select images
images = cell(1, size(samples,2));
color_images=cell(1, size(samples,2));
for i=1:size(samples,2)
    I = readimage(imds, samples(i));
    images{i} = rgb2gray(I);
    color_images{i}=I;
end

end

