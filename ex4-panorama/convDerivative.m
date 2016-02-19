function [ Ix, Iy ] = convDerivative( inImage )
%convDerivative Returns a derivative magnitude's of an image 
% using convolution with [1 0 -1] and [1 ; 0 ; -1].

    narginchk(1, 1);
    nargoutchk(0, 2);

    try
        Ix = conv2(inImage, [1 0 -1], 'same');
        Iy = conv2(inImage, [1 ; 0 ; -1], 'same');

    catch err
        disp(strcat('ERROR: ', err.identifier));
        Ix = [];
        Iy = [];
    end

end

