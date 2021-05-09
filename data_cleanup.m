%% Load video
clear;
clc;
v=VideoReader('Video FOGO_1.avi');

%% Crop example
I1=read(v,1113);
I2=I1(90:720,120:1060,:);
figure();
imshow(I1);
figure();
imshow(I2);
%% Remove frames and store them

for i=1114:5:2670
    frame=read(v,i);
    frame=frame(90:720,120:1060,:); %crop
    frame_name=strcat(int2str((i-1114)/5 +1),'.png');
    imwrite(frame, strcat('Dataset/',frame_name));
end
