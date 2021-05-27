%% Load video
clear;
clc;
v=VideoReader('Videos/UAVision video_part2_720p.avi');
fprintf('Video Duration:%f\nFPS:%f\n',v.Duration,v.FrameRate);

%% Define dataset parameters
dataset_name="B_0_1_34";
s=sscanf(dataset_name,"%c_%d_%d_%d");
source=char(s(1));
t0=s(2);
step=s(3)*v.FrameRate;
tf=s(4);
%% Define image parameters
window_x=[90,720]; window_y=[135,1060];
frame1=1+t0*v.FrameRate;
frames=frame1:step:1+tf*v.FrameRate; frames=round(frames);
nframes=size(frames,2);
%% Build image dataset
% 1st, save croped images
image_count=1;
pitch=zeros(nframes,1); heading=zeros(nframes,1);
gps=zeros(nframes,2); % LAT LON
altitude=zeros(nframes,1);
speed=zeros(nframes,1);
for i=1:nframes
    
    I=read(v,frames(i));
    % crop image and save it
    if image_count>=10
        filename=strcat(dataset_name,'/',int2str(image_count),'.png');
    else
        filename=strcat(dataset_name,'/0',int2str(image_count),'.png');
    end
    image_count=image_count+1;
    imwrite(I(window_x(1):window_x(2),window_y(1):window_y(2),:),filename);
    
    % Ask parameters
    h=figure();
    imshow(I);
    gps(i,1)=input("Insert Latitude:\n");
    gps(i,2)=input("Insert Longitude:\n");
    altitude(i)=input("Insert altitude in feet:\n")*0.3048;
    speed(i)=input("Insert speed in knots:\n")*0.514444;
    heading(i)=input("Insert heading:\n");
    pitch(i)=-1*input("Insert pitch (without negative sign)\n");
    close(h);
    fprintf("Frame %d Done\n",i);
    
end
%% create telemetry vector 
% gps, altitude and speed are done automatically
% heading and pitch are done manually

% % detect gps, altitude and speed first
% gps=zeros(nframes,2); % LAT LON
% altitude=zeros(nframes,1);
% speed=zeros(nframes,1);
% h=waitbar(0,"Processing telemetry");
% for i=1:nframes
%     I=read(v,frames(i));
%     gps(i,:)=OCR_gps(I);
%     altitude(i)=OCR_alt(I);
%     speed(i)=OCR_speed(I);
%     waitbar(i/nframes,h);
% end
% close(h);
% % ask for heading and pitch manually
% pitch=zeros(nframes,1); heading=zeros(nframes,1);
% for i=1:nframes
%     I=read(v,frames(i));
%     h=figure;
%     imshow(I);
%     heading(i)=input("Insert heading:\n");
%     pitch(i)=-1*input("Insert pitch (without negative sign)\n");
%     close(h);
% end
% ask target coordinates and convert them to NED
I=read(v,frames(1));
h=figure; imshow(I(62:140,1060:1280,:));
target_lat=input("Insert target latitude:\n");
target_lon=input("Insert target longitude:\n");
close(h);
origin=[gps(1,:) ,altitude(1)];
[xeast,ynorth]=latlon2local(target_lat,target_lon,0,origin);
target=[xeast ynorth 0];

%% save results
filename=strcat(dataset_name,'/','extrinsics.mat');
save(filename,'pitch','heading','gps','altitude','speed','target');