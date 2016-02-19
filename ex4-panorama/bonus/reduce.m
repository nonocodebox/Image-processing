function [ smallImage ] = reduce(inImage, filter)
%REDUCE Reduces a given image by 2, using blurring with a givan filter
% and sampling.

    narginchk(2, 2);
    nargoutchk(0, 1);

    try
        blurImg = conv2(inImage, filter, 'same');
        blurImg = conv2(blurImg, filter', 'same');

        smallImage = blurImg(1:2:end, 1:2:end);

    catch err
        disp(strcat('ERROR: ', err.identifier));
        smallImage = [];
    end

end

