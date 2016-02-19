function [ denoisImage ] = filterNoisyImage(  )
%FILTERNOISYIMAGE Filters myNoisyImage.png using denoising.m
    
    narginchk(0, 0);
    nargoutchk(0, 1);
    
    try
        image = im2double(imread('myNoisyImage.png'));
        denoisImage = denoising(image, [0.5 0.5], [0.5 -0.5], 8);
    catch err
        disp(strcat('ERROR: ', err.identifier));
        denoisImage = [];
    end
end

