function [heading,lat,lon,alt,speed] = telemetry_extractor(video,frames)
%TELEMETRY_EXTRACTOR Summary of this function goes here
%   Detailed explanation goes here
heading=zeros(size(frames,2),1);
lat=zeros(size(frames,2),1);
lon=zeros(size(frames,2),1);
alt=zeros(size(frames,2),1);
speed=zeros(size(frames,2),1);
for i=frames
    I=read(video,i);
    
    % heading loop
    
    
    % latitude
    
    % longitude
    
    % altitude
    
    % speed
end
end

