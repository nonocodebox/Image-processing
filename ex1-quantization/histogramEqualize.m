function [ imEq, histOrig, histEq ] = histogramEqualize( imOrig )
%histogramEqualize calculates an image's histogram, an image after
 % a histogram equalization and its histogram.

try
    % a RGB histogram equalization calculation is proformed on Y's matrix. 
    working_mat = imOrig;
    
    % Get the image size and dimension
    im_size = size(imOrig);
    org_size = size(im_size);
    
    % Check if this is a RGB image
    flag_RGB = (org_size(2) == 3 && im_size(3) == 3);
    if flag_RGB
        % Convert to YIQ and get the Y channel
        imOrig_YIQ = transformRGB2YIQ(imOrig);
        working_mat = imOrig_YIQ(:,:,1);
    end

    % Calculate the histogram, cumulative histogram and number of pixels
    histOrig = imhist(working_mat);
    cumulative_org = cumsum(histOrig);
    number_of_pixels = sum(histOrig);

    % Calculate the normalized cumulative histogram
    normalized_cumulative = (double(cumulative_org) ./ number_of_pixels) .* 255;
    normalized_cumulative = round(normalized_cumulative);
    
    % Map the image using the normalized cumulative histogram
    result = double(normalized_cumulative(1 + round(working_mat * 255)));
    
    % Stretch to the range of [0...255]
    min_gray_level = min(result(:));
    max_gray_level = max(result(:));
    
    % In case of one color image, we can't stretch
    if min_gray_level ~= max_gray_level 
        result = result - min_gray_level;
        result = (result * 255) / (max_gray_level - min_gray_level);
    end
    
    % Transform back to [0,1] and calculate the histogram
    final_im_eq = result / 255;
    histEq = imhist(final_im_eq);

    if flag_RGB
        % For RGB images replace the Y channel and convert back to RGB
        imEq = imOrig_YIQ;
        imEq(:,:,1) = final_im_eq;
        imEq = transformYIQ2RGB(imEq);
    else
        imEq = final_im_eq;
    end
    
    % Show the equalized image alongside the original image
    figure;
    imshow([imOrig imEq]);
    
 catch err
    disp(strcat('ERROR: ', err.identifier));
    imEq = [];
    histOrig = [];
    histEq = [];
    return;
end

