function [alt] = OCR_alt(I)
%OCR_alt Return altitude in metres
%   Detailed explanation goes here

altitude_image=I(680:700,1140:1200,:);
altitude_text=ocr(altitude_image ...
    ,'CharacterSet','0123456789','TextLayout','Line');
alt=str2double(altitude_text.Text)*0.3048;

end

