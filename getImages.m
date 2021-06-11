function [images,color_images] = getImages(imds,samples)

% select images
images = cell(1, size(samples,2));
color_images=cell(1, size(samples,2));
for i=1:size(samples,2)
    I = readimage(imds, samples(i));
    images{i} = rgb2gray(I);
    color_images{i}=I;
end

end

