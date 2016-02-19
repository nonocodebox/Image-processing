function [ imRGB ] = transformYIQ2RGB( imYIQ )
%transformYIQ2RGB transforms a YIQ image to RGB

try
    RGB2YIQ_mat = [0.299 0.587 0.114; 0.596 -0.275 -0.321; 0.212 -0.523 0.311];
    
    % Calculate the image size
    in_size_elem = size(imYIQ);
    in_size = in_size_elem(1) * in_size_elem(2);

    % Change an input image to the form (Y  Y .. )
    %                                   (I  I .. )
    %                                   (Q  Q .. )
    pixel_YIQ_index = reshape(imYIQ, in_size, 3)';

    % Multiply with the convert matrix to RGB each pixel,
    % now we get:(R R R .. )
    %            (G G G .. )
    %            (B B B .. )
    %
    % Division means multiply with the inverse matrix.
    result_mat = RGB2YIQ_mat \ pixel_YIQ_index;

    % Transpose in order to form the matrix to ( R G B )
    %                                          ( R G B )
    %                                          ( . . . )
    % and reshape to an image matrix form.
    imRGB = reshape(result_mat', in_size_elem);

catch err
    disp(strcat('ERROR: ', err.identifier));
    imRGB = [];
    return;
end

