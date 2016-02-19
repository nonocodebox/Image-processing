function [ image ] = IDFT2( fourierImage )
%IDFT2 Revereses 2D fourier transform into signal space.

narginchk(1, 1);
nargoutchk(0, 1);

try
    image = IDFT((IDFT(fourierImage.')).');
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    image = [];
end

end

