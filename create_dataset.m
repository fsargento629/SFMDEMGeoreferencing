%% create pxin
imageDir='Datasets/Blender datasets/Vila_real/V1';
imds = imageDatastore(imageDir);

% select images (only the selected samples
images = cell(1, numel(imds.Files));
color_images=cell(1, numel(imds.Files));
for i=1:numel(imds.Files)
    I = readimage(imds, i);
    images{i} = I;
    
end
%% names
names=["VL1","VL2","VL3","VL4","VL5","VL6","VL7","VL8"];
id=[1,1,1,1,20,20,20,20];
pxin=zeros(8,2);
%% ginput
figure;imshow(images{20});
px=ginput(1);

%% add
pxin(i,:)=px;
i=i+1;
disp(pxin);

%% ttrue
ttrue=zeros(8,3);