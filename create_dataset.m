%% Load video
clear;
clc;
v=VideoReader('UAVision video_part1_720p.avi');
fprintf('Video Duration:%f\nFPS:%f\n',v.Duration,v.FrameRate);
%% Select 1st frame, number of frames and time between frames
frame1=input("Insert 1st frame's time:\n")*v.FrameRate;
nframes=input("Insert number of frames:\n");
rate=input("Insert time difference between sampled frames:\n")*v.FrameRate;
dataset_name=input("Insert dataset name:\n",'s');

%% Show 1st frame
I=read(v,frame1); imshow(I);

%% Show window size
window_x=[90,720]; window_y=[135,1060];
%imshow(I(x(1):x(2),y(1):y(2),:));
%figure;
%imshow(I);
%% Build image dataset
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
end

%% Build telemetry vector 

time=zeros(nframes,3); %h m ms
pitch=zeros(nframes,1); heading=zeros(nframes,1);
gps=zeros(nframes,2); % LAT LON
altitude=zeros(nframes,1);
speed=zeros(nframes,1);


for i=1:nframes
    I=read(v,round(frame1+(i-1)*rate));
    disp(i);
    % detect time
    time_image=I(1:20,1:300,:);
    time_text=ocr(time_image,'CharacterSet','0123456789','TextLayout','Line');
    time(i,1)=str2double(time_text.Text(11:12));%hour
    time(i,2)=str2double(time_text.Text(14:15));%minutes
    time(i,3)=1000*str2double(time_text.Text(17:18));%seconds
    time(i,3)=time(i,3)+str2double(time_text.Text(19:22));%ms
    
    
    % detect heading, using a loop to test every part of the horizontal bar
    n1=NaN;
    for y=470:5:810
    heading_image=I(72:88,y:y+30,:);
    heading_text=ocr(heading_image,'CharacterSet','0123456789','TextLayout','Word');
    n2=str2double(heading_text.Text);
      
    if n1==n2
        count=count+1;  
        if count==2
            break;
        end
    else
        count=0;
    end
    
    n1=n2;
    end
    heading(i)=n2; %in deg
    
    
    % detect pitch using a loop to test every part of the vertical bar
    n1=NaN;
    for x=170:5:500
        pitch_image=I(x:x+30,90:135,:);
        pitch_text=ocr(pitch_image,'CharacterSet','0123456789','TextLayout','Word');
        n2=str2double(pitch_text.Text);

        if n1==n2
            count=count+1;  
            if count==3
                break;
            end
        else
            count=0;
        end

        n1=n2;
    end
    pitch(i)=-n2;
    
    % detect gps
    try
        gps_image=I(640:680,1140:1260,:);
        gps_text=ocr(gps_image,'CharacterSet','0123456789','TextLayout','Block');
        gps_text=gps_text.Text;
        gps(i,1)=str2double(gps_text(1:2))+1e-5*str2double(gps_text(4:9));
        gps(i,2)=-str2double(gps_text(11))-1e-5*str2double(gps_text(13:19));
    catch
        fprintf("Error scanning gps\n");
    end
    
    % detect altitude
    altitude_image=I(680:700,1140:1200,:);
    altitude_text=ocr(altitude_image,'CharacterSet','0123456789','TextLayout','Line');
    altitude(i)=str2double(altitude_text.Text)*0.3048; % ft to metres
    % detect speed
    speed_image=I(700:720,1140:1170,:);
    speed_text=ocr(speed_image,'CharacterSet','0123456789','TextLayout','Line');
    speed(i)=str2double(speed_text.Text)*0.514444444; % kts to m/s
end

%% save vectors in the directory of the images
filename=strcat(dataset_name,'/','extrinsics.mat');
save(filename,'time','pitch','heading','gps','altitude','speed');
