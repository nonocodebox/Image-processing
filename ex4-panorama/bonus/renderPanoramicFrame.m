function [ panoramaFrame, frameNotOK ] = renderPanoramicFrame(panoSize, imgs, T, imgSliceCenterX, halfSliceWidthX)
%
% The function render a panoramic frame. It does the following:
% 1. Convert centers into panorama coordinates and find optimal width of
% each strip.
% 2. Backwarpping each strip from image to the panorama frames
%
% Arguments:
% panoSize - [yWidth,xWidth] of the panorama frame
% imgs - The set of M images
% T - The set of transformations (cell array) from each image to
% the panorama co ordinates
% imgSliceCenterX - A vector of 1xM with the required center of the strip
% in each of the images. This is given in image co ordinates.
% sliceWidth - The suggested width of each strip in the image
%
% Returns:
% panoramaFrame - the rendered frame
% frameNotOK - in case of errors in rednering the frame, it is true.

    narginchk(5, 5);
    nargoutchk(0, 2);

    try
        OVERFLOW_TOLERANCE = 1; % Allow overflows by up to 1 pixel from the image borders
        FRAME_CHECK_OK = 0; % Enable frame checking. Disable this if too many frames are dropped
        
        frameNotOK = false;
        nfiles = size(imgs, 4);
        
        corners = calculatePanoramicBorders(imgs, T, panoSize, imgSliceCenterX, halfSliceWidthX);
        
        % Create an empty frame
        panoramaFrame = zeros(panoSize(1), panoSize(2), 3);
        
        for i = 1:nfiles
            % Transform the panorama corners to MATLAB format (y, x)
            corner1 = corners(:, 1, i); % TL
            corner3 = corners(:, 3, i); % BR
            
            if FRAME_CHECK_OK
                % Convert the corners to homogenous coordinates
                hcorners = ones(4, 1, 3);
                hcorners(1, 1, [2 1]) = corners(:, 1, i);
                hcorners(2, 1, [2 1]) = corners(:, 2, i);
                hcorners(3, 1, [2 1]) = corners(:, 3, i);
                hcorners(4, 1, [2 1]) = corners(:, 4, i);

                % Transform the corners to image coordinates
                strip_corners_image = transform(hcorners, inv(T{i}));

                % Get the image width and height.
                W = size(imgs, 2);
                H = size(imgs, 1);
                
                % Create the image corners in image coordinates
                image_corners(1, 1, :) = [ 1-OVERFLOW_TOLERANCE 1 1 ]; % TL
                image_corners(2, 1, :) = [ W+OVERFLOW_TOLERANCE 1 1 ]; % TR
                image_corners(3, 1, :) = [ W+OVERFLOW_TOLERANCE H 1 ]; % BR
                image_corners(4, 1, :) = [ 1-OVERFLOW_TOLERANCE H 1 ]; % BL
                
                % Check which side of the edge each corner is
                right_p1 = checkLineSide(image_corners(3, 1, :), image_corners(2, 1, :), strip_corners_image(2, 1, :));
                right_p2 = checkLineSide(image_corners(3, 1, :), image_corners(2, 1, :), strip_corners_image(3, 1, :));
                left_p1 = checkLineSide(image_corners(4, 1, :), image_corners(1, 1, :), strip_corners_image(1, 1, :));
                left_p2 = checkLineSide(image_corners(4, 1, :), image_corners(1, 1, :), strip_corners_image(4, 1, :));
                
                overflowLeft = (left_p1 < 0) || (left_p2 < 0); % On the left we need a positive cross product
                overflowRight = (right_p1 > 0) || (right_p2 > 0); % On the right we need a negative cross product
                
                if overflowLeft || overflowRight
                    frameNotOK = true;
                    break;
                end
            end
            
            
            %{
            if FRAME_CHECK_OK
                W = size(imgs, 2);
                H = size(imgs, 1);
                
                % Convert the image corners to homogenous coordinates
                hcorners = ones(4, 1, 3);
                hcorners(1, 1, :) = [ 1 1 1 ]; % TL
                hcorners(2, 1, :) = [ W 1 1 ]; % TR
                hcorners(3, 1, :) = [ W H 1 ]; % BR
                hcorners(4, 1, :) = [ 1 H 1 ]; % BL

                % Transform the corners to image coordinates
                corners_pano = transform(hcorners, T{i});
                
                % Calculate the minimal and maximal X values
                max_left_x = min(corners_pano([1 4], 1, 1));
                min_right_x = max(corners_pano([2 3], 1, 1));
                
                 % Check if we have overflowed on left or right
                overflowLeft = max_left_x > corner1(2);
                overflowRight = min_right_x < corner3(2);

                if overflowLeft || overflowRight
                    frameNotOK = true;
                    break;
                end
            end
            %}
            
            % Extract the R, G and B strips using the corners
            strip_r = imageWarp(imgs(:,:,1,i), inv(T{i}), corner1, corner3);
            strip_g = imageWarp(imgs(:,:,2,i), inv(T{i}), corner1, corner3);
            strip_b = imageWarp(imgs(:,:,3,i), inv(T{i}), corner1, corner3);

            % Get the strip X values
            if corner3(2) > corner1(2)
                strip_x = corner1(2) : corner3(2);
            else
                strip_x = corner3(2) : corner1(2);
            end

            % Get the strip Y values
            if corner3(1) > corner1(1)
                strip_y = corner1(1) : corner3(1);
            else
                strip_y = corner3(1) : corner1(1);
            end
            
            % Round X and Y, indices are integers.
            strip_x = round(strip_x);
            strip_y = round(strip_y);
            
            % Insert the strip into the panorama
            if all(strip_x(:) > 0) && all(strip_y(:) > 0)
                panoramaFrame(strip_y, strip_x, 1) = strip_r;
                panoramaFrame(strip_y, strip_x, 2) = strip_g;
                panoramaFrame(strip_y, strip_x, 3) = strip_b;
            end
        end

    catch err
        disp(strcat('ERROR: ', err.identifier));
        frameNotOK = true;
    end
end

% This function checks which side of a line segment a point lies.
%  0 means the point is on the line.
% 1 and -1  means two sides. The sign of the result is determind by
% performing a cross product between the line segment (vector line_a to line_b)
% and the vector line_a to point.
function  [ side ] = checkLineSide(line_a, line_b, point)   
    vec_line = line_b - line_a;
    vec_point = point - line_a;
    side = sign(vec_line(1) * vec_point(2) - vec_line(2) * vec_point(1));
end
