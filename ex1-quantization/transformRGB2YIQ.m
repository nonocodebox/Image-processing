function [ imYIQ ] = transformRGB2YIQ( imRGB )
%transformRGB2YIQ transforms a RGB image to YIQ.

try
    RGB2YIQ_mat = [0.299 0.587 0.114; 0.596 -0.275 -0.321; 0.212 -0.523 0.311];

    % Calculate the image size
    in_size_elem = size(imRGB);
    in_size = in_size_elem(1) * in_size_elem(2);

    % Change an input image to the form (R  R .. )
    %                                   (G  G .. )
    %                                   (B  B .. )
    pixel_RGB_index = reshape(imRGB, in_size, 3)';

    % Multiply with the convert matrix to YIQ each pixel,
    % now we get:(Y Y Y .. )
    %            (I I I .. )
    %            (Q Q Q .. )
    result_mat = RGB2YIQ_mat * pixel_RGB_index;

    % Transpose in order to form the matrix to ( Y I Q )
    %                                          ( Y I Q )
    %                                          ( . . . )
    % and reshape to an image matrix form.
    imYIQ = reshape(result_mat', in_size_elem);
    
catch err
    disp(strcat('ERROR: ', err.identifier));
    imYIQ = [];
    return;
end

