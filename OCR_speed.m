function speed = OCR_speed(I)
%OCR_speed Return speed in m/s
%   Detailed explanation goes here
speed_image=I(700:720,1140:1170,:);
speed_text=ocr(speed_image ...
    ,'CharacterSet','0123456789','TextLayout','Line');
speed=str2double(speed_text.Text)*0.514444444;
end

