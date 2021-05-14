%% Load video
clear;
clc;
v=VideoReader('UAVision video_part1_720p.avi');
%v=VideoReader('Video FOGO_1.avi');
%% Crop example
I1=read(v,1113);
I2=I1(90:720,120:1060,:);
figure();
imshow(I1);
figure();
imshow(I2);
%% Remove frames and store them
input("Press enter\n");
for i=0:5:55
    frame=read(v,i*30+1);
    frame_name=strcat(int2str(i),'.png');
    imwrite(frame, strcat('UAVision_Dataset/',frame_name));
end

%% show image
I=read(v,1);
figure;
imshow(I);

%% Crop time
time=I(1:20,1:300,:);
imshow(time);
time_text=ocr(time,'CharacterSet','0123456789','TextLayout','Line');
disp(time_text.Text);
%% Find heading
t=input("Insert time frame:\n");
I=read(v,t*30+1);
% Crop heading
heading=I(72:88,470:810,:);
%heading=I(72:88,510:540,:); % correct
   
imshow(heading);
% heading loop
n1=NaN;
for y=470:5:810
    disp((810-y)/(810-470));
    heading=I(72:88,y:y+30,:);
    heading_text=ocr(heading,'CharacterSet','0123456789','TextLayout','Word');
    text=heading_text.Text;
    n2=str2double(text);
    %disp(n2);    
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
disp(n2);

%% Find pitch
% Crop pitch
t=input("Insert time frame:\n");
I=read(v,t*30+1);imshow(I);
pitch=I(190:530,105:141,:);
%pitch=I(370:400,90:135,:);
%imshow(pitch);
pitch_text=ocr(pitch,'CharacterSet','0123456789','TextLayout','Word');


% pitch loop
n1=NaN;
for x=170:2:500
    pitch=I(x:x+30,105:135,:);
    pitch_text=ocr(pitch,'CharacterSet','0123456789','TextLayout','Word');
    text=pitch_text.Text;
    n2=str2double(text);
    disp(x);
    if n1==n2
        count=count+1;  
        if count==6
            break;
        end
    else
        count=0;
    end
    
    n1=n2;
end
disp(n2);
%% Crop gps 
gps=I(640:680,1140:1260,:);
imshow(gps);
gps_text=ocr(gps,'CharacterSet','0123456789','TextLayout','Block');
disp(gps_text.Text);
%% Crop Altitude
altitude=I(680:700,1140:1200,:);
imshow(altitude);
altitude_text=ocr(altitude,'CharacterSet','0123456789','TextLayout','Line');
disp(altitude_text.Text);
%% Crop speed
speed=I(700:720,1140:1170,:);
imshow(speed);
speed_text=ocr(speed,'CharacterSet','0123456789','TextLayout','Line');
disp(speed_text.Text);
%% detect and read
clear text;
text=ocr(pitch,'CharacterSet','0123456789');
disp(text);