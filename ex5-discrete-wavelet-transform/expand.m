function [ bigImage ] = expand(inImage, filter, flagRow)
%EXPAND expends image by zero padding and bluring with 2*filter.
    narginchk(3, 3);
    nargoutchk(0, 1);
    
try
    image_size = size(inImage);
    rows = image_size(1);
    cols = image_size(2);

    if (flagRow == 1)
        bigImg = zeros(rows*2, cols);
        bigImg(2:2:end, :) = inImage;
    else
        bigImg = zeros(rows, cols*2);
        bigImg(:, 2:2:end) = inImage;
    end
    
    bigImage = conv2(bigImg, 2*filter, 'same');
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    bigImage = [];
end