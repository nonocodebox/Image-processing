function [ ] = blendingExample2()
%blendingExample2 creates a birdboon.

try
    I1=imReadAndConvert('bird2b.jpg', 2);
    I2=imReadAndConvert('baboon1b.jpg', 2);
    M=imReadAndConvert('baboon-mask11.jpg', 2);
    birdboon = BlendRGBImages(I1, I2, M, 6, 8, 3);

    figure; imshow(I1);
    figure; imshow(I2);
    figure; imshow(M);
    figure; imshow(birdboon);
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    return;
end

end

