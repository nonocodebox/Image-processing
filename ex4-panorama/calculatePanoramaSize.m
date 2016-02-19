function [ panoramaSize, panoramaOffset ] = calculatePanoramaSize( imgs, transformations )
%calculatePanoramaSize Calculates the panorama size and offset
% given the images and transformations

    narginchk(2, 2);
    nargoutchk(0, 2);

    try
        PADDING = 0; % We don't really need padding since we already calculate the panorama offset
        
        % Get the number of images
        imgs_size = size(imgs, 4);

        W = size(imgs, 2);
        H = size(imgs, 1);

        % Calculate the coordinates of any image in the sequence (in image
        % coordinates)
        single_image_corners = ones(4, 1, 3);
        single_image_corners(:, 1, :) = [ 1 1 1 ; W 1 1 ; W H 1 ; 1 H 1 ];

        image_corners = zeros(4 * imgs_size, 1, 3);
        
        % Transform each image's corners to the panorama coordinates
        for i = 1:imgs_size
            image_corners((i*4-3):(i*4),:,:) = transform(single_image_corners, transformations{i});
        end

        % Calculate the width and height of the panorama
        panorama_width = max(image_corners(:, :, 1)) - min(image_corners(:, :, 1)) + 1;
        panorama_height = max(image_corners(:, :, 2)) - min(image_corners(:, :, 2)) + 1;
        panoramaSize = [ panorama_height, panorama_width ];
        panoramaSize = ceil(panoramaSize);

        % Calculate the offset of the panorama (in case images are
        % advancing to the left)
        panorama_offset_x = min(image_corners(:, :, 1)) - 1;
        panorama_offset_y = min(image_corners(:, :, 2)) - 1;
        panoramaOffset = [ panorama_offset_y, panorama_offset_x ];
        panoramaOffset = floor(panoramaOffset);
        
        % Add some padding
        panoramaOffset = panoramaOffset - PADDING;
        panoramaSize = panoramaSize + 2 * PADDING;
        
    catch err
        disp(strcat('ERROR: ', err.identifier));
        panoramaSize = [ ];
        panoramaOffset = [ ];
    end
end
