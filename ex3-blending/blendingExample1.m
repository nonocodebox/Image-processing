function [ ] = blendingExample1( )
%blendingExample1 creates an eye mix.

try
    I2=imReadAndConvert('blue576_416_center.jpg', 2);
    I1=imReadAndConvert('brown576_416.jpg', 2);
    M=imReadAndConvert('mask-eye.jpg', 2);
    mixedEyes = BlendRGBImages(I1, I2, M, 5, 8, 3);

    figure; imshow(I1);
    figure; imshow(I2);
    figure; imshow(M);
    figure; imshow(mixedEyes);
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    return;
end

end

