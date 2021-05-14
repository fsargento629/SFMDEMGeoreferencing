%% Create Dataset
clear;
clc;
v=VideoReader('UAVision video_part1_720p.avi');
I=read(v,50);
% Image regions
% heading
heading_x=72:88;
heading_y=470:810;
% pitch
pitch_x=190:530;
pitch_y=86:141;
% Latitude
lat_x=640:660;
lat_y=1140:1260;
% Longitude
lon_x=660:680;
lon_y=1158:1260;
% Altitude
alt_x=680:700;
alt_y=1140:1200;
% Speed
speed_x=700:720;
speed_y=1140:1170;

% define dataset length
frame1=1;
rate=60;% 
nframes=30;

%% save cropped images
dir_name='OCR_trainer/trainers/';
tic;
for i=round(frame1:rate:frame1+rate*nframes)
    I=read(v,i);
    % heading
    filename=strcat(dir_name,'heading_',int2str(i),'.png');
    imwrite(I(heading_x,heading_y,:),filename);
    % pitch
    filename=strcat(dir_name,'pitch_',int2str(i),'.png');
    imwrite(I(pitch_x,pitch_y,:),filename);
    % latitude
    filename=strcat(dir_name,'lat_',int2str(i),'.png');
    %imwrite(I(lat_x,lat_y,:),filename);
    % longitude
    filename=strcat(dir_name,'lon_',int2str(i),'.png');
    %imwrite(I(lon_x,lon_y,:),filename);
    % altitude
    filename=strcat(dir_name,'alt_',int2str(i),'.png');
    %imwrite(I(alt_x,alt_y,:),filename);
    % speed
    filename=strcat(dir_name,'speed_',int2str(i),'.png');
    %imwrite(I(speed_x,speed_y,:),filename);
end
toc;
%% call ocr for a specific frame
clc;
I=read(v,605); imshow(I);
[~, lat_results] = OCR_simple(I(lat_x,lat_y)); disp(lat_results.Text);
[~, lon_results] = OCR_simple(I(lon_x,lon_y)); disp(lon_results.Text);
[~, alt_results] = OCR_simple(I(alt_x,alt_y)); disp(alt_results.Text);
[~, speed_results] = OCR_simple(I(speed_x,speed_y)); disp(speed_results.Text);
%% pitch and heading
clc;
I=read(v,605); imshow(I);
[~, pitch_results] = OCR_simple(I(pitch_x,pitch_y)); disp(pitch_results.Text);
[~, heading_results] = OCR_simple(I(heading_x,heading_y)); disp(heading_results.Text);

%% Test loop
t0=1;
deltat=5;
tf=55;

for i=1:(tf-t0)/deltat
    I=read(v,i*30);
    [~, lat_results] = OCR_simple(I(lat_x,lat_y)); lat(i)=str2double(lat_results.Text);
    [~, lon_results] = OCR_simple(I(lon_x,lon_y)); lon(i)=str2double(lon_results.Text);
    [~, alt_results] = OCR_simple(I(alt_x,alt_y)); alt(i)=str2double(alt_results.Text);
    [~, speed_results] = OCR_simple(I(speed_x,speed_y)); speed(i)=str2double(speed_results.Text);
    [~, pitch_results] = OCR_simple(I(pitch_x,pitch_y)); pitch(i)=str2double(pitch_results.Text);
    [~, heading_results] = OCR_simple(I(heading_x,heading_y)); heading(i)=str2double(heading_results.Text);
end

%% pitch
I=imread('UAVision_Dataset/10.png');
[~, heading_results] = OCR_simple(I); disp(heading_results);