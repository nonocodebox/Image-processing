function [ transformed_coords ] = transform( coords, tform )
%Transform transforms coordinates using a transformation matrix.

    narginchk(2, 2);
    nargoutchk(0, 1);

    try
        % Calculate the image size
        in_size_elem = size(coords);
        in_size = in_size_elem(1) * in_size_elem(2);

        % Change input coordinates to the form (X  X .. )
        %                                      (Y  Y .. )
        %                                      (Z  Z .. )
        pixel_XYZ_index = reshape(coords, in_size, 3)';

        % Multiply with the transform matrix to transform each pixel,
        % now we get:(tX tX tX .. )
        %            (tY tY tY .. )
        %            (tZ tZ tZ .. )
        result_mat = tform * pixel_XYZ_index;

        % Transpose in order to form the matrix to ( tX tY tZ )
        %                                          ( tX tY tZ )
        %                                          ( .  .  .  )
        % and reshape to a coordinate matrix form.
        transformed_coords = reshape(result_mat', in_size_elem);

    catch err
        disp(strcat('ERROR: ', err.identifier));
        transformed_coords = [];
    end
end
