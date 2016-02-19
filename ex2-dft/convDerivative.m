function [ magnitude ] = convDerivative( inImage )
%convDerivative Returns a derivative magnitude's of an image 
% using convolution with [1 0 -1] and [1 ; 0 ; -1].

narginchk(1, 1);
nargoutchk(0, 1);

try
    
    derivative_x = conv2(inImage, [1 0 -1], 'same');
    derivative_y = conv2(inImage, [1 ; 0 ; -1], 'same');

    magnitude = sqrt(derivative_x.^2 + derivative_y.^2);

catch err
    disp(strcat('ERROR: ', err.identifier));
    magnitude = [];
end

imshow(magnitude);

end

