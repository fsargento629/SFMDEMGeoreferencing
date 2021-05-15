%% Load video
clear;
clc;
v=VideoReader('UAVision video_part2_720p.avi');
fprintf('Video Duration:%f\nFPS:%f\n',v.Duration,v.FrameRate);
%% Select 1st frame, number of frames and time between frames
frame1=input("Insert 1st frame's time:\n")*v.FrameRate;
nframes=input("Insert number of frames:\n");
rate=input("Insert time difference between sampled frames:\n")*v.FrameRate;
dataset_name=input("Insert dataset name:\n",'s');


%% Show window size
window_x=[90,720]; window_y=[135,1060];

%% Define telemetry datasets
pitch=zeros(nframes,1); heading=zeros(nframes,1);
gps=zeros(nframes,2); % LAT LON
altitude=zeros(nframes,1);
speed=zeros(nframes,1);
time=frame1:rate:frame1+rate*nframes;
%% Build image dataset
% Crop image and save it in folder
% Show full image and ask for the parameters
% repeat
image_count=1;%to save the images as 01,02,...,09,10,...
for i=1:nframes
    I=read(v,round(frame1+(i-1)*rate));
    % crop image and save it
    if image_count>=10
        filename=strcat(dataset_name,'/',int2str(image_count),'.png');
    else
        filename=strcat(dataset_name,'/0',int2str(image_count),'.png');
    end
    image_count=image_count+1;
    imwrite(I(window_x(1):window_x(2),window_y(1):window_y(2),:),filename);
    % Ask parameters
    figure();
    imshow(I);
    gps(i,1)=input("Insert Latitude:\n");
    gps(i,2)=input("Insert Longitude:\n");
    altitude(i)=input("Insert altitude in feet:\n")*0.3048;
    speed(i)=input("Insert speed in knots:\n")*0.514444;
    heading(i)=input("Insert heading:\n");
    pitch(i)=-1*input("Insert pitch (without negative sign)\n");
    fprintf("Frame %d Done\n",i);
end

%% Save telemetry data
filename=strcat(dataset_name,'/','extrinsics.mat');
save(filename,'time','pitch','heading','gps','altitude','speed');