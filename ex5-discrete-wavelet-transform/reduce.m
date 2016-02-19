function [ smallImage ] = reduce(inImage, filter, flagRow)
%REDUCE Reduces a given image by 2, using blurring with a givan filter
% and sampling.

     narginchk(3, 3);
     nargoutchk(0, 1);

    try
        blurImg = conv2(inImage, filter, 'same');
        
        if (flagRow == 1)
            smallImage = blurImg(1:2:end, :);
        else
            smallImage = blurImg(:, 1:2:end);
        end
        

    catch err
        disp(strcat('ERROR: ', err.identifier));
        smallImage = [];
    end

end
