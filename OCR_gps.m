function gps = OCR_gps(I)
%OCR_gps Returns the gps coordinates of 
%   Detailed explanation goes here
%% latitude
lat_image1=I(640:660,1140:1170);
lat_text1=ocr(lat_image1,'CharacterSet','0123456789','TextLayout','Block');
lat1=str2double(lat_text1.Text);
lat_image2=I(640:660,1185:1260);
lat_text2=ocr(lat_image2,'CharacterSet','0123456789','TextLayout','Block');
lat2=str2double(lat_text2.Text);

lat=lat1+1e-5*lat2;

%% longitude
lon_image1=I(660:680,1155:1170);
lon_text1=ocr(lon_image1,'CharacterSet','0123456789','TextLayout','Block');
lon1=str2double(lon_text1.Text);
lon_image2=I(660:680,1185:1260);
lon_text2=ocr(lon_image2,'CharacterSet','0123456789','TextLayout','Block');
lon2=str2double(lon_text2.Text);

lon=lon1+1e-5*lon2;

%% return
gps=[lat,lon];
end

