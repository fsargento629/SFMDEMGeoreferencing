%% load video
clear;
v=VideoReader('Videos/AF_oeste.avi');
fprintf('Video Duration:%f\nFPS:%f\n',v.Duration,v.FrameRate);
%% parse video
frate=v.NumFrames/v.Duration;
save_dir='Datasets\Real_datasets\oeste_2';
t0= 0*60+10;
tf=0*60+15;
dt=0.25;
frames=(t0*frate:dt*frate:tf*frate)+1;
%window_x=[90,720]; window_y=[135,1060]; % uavision
window_x=[95,1080]; window_y=[490,1708]; % AF oeste
image_count=0;
for f=frames
    I=read(v,round(f));
    % crop image and save it
    if image_count>=10
        filename=strcat(save_dir,'/',int2str(image_count),'.png');
    else
        filename=strcat(save_dir,'/0',int2str(image_count),'.png');
    end
    image_count=image_count+1;
    imwrite(I(window_x(1):window_x(2),window_y(1):window_y(2),:),filename);
end
%% extrinsics
I=read(v,round(frames(1))); imshow(I);
heading=28;
pitch=-25;
origin=[41.286959,-7.242982,6237.4*0.3048];
speed=59.9*0.514444444;
save(strcat(save_dir,'/extrinsics'),... 
    'heading','pitch','origin','speed','dt');



