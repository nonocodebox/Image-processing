function [ im2 ] = imageWarp(im, tform, p1, p2)
%IMAGEWARP Backwarps a rectangle from an image using a given transformations
%   The rectangle to backwarp is identified by corners p1 and p2

    narginchk(4, 4);
    nargoutchk(0, 1);

    try
        % Get the start and end X values from the corners
        if p2(2) > p1(2)
            x_start = p1(2);
            x_end = p2(2);
        else
            x_start = p2(2);
            x_end = p1(2);
        end
        
        % Get the start and end Y values from the corners
        if p2(1) > p1(1)
            y_start = p1(1);
            y_end = p2(1);
        else
            y_start = p2(1);
            y_end = p1(1);
        end
        
        % Create the image coordinates
        [x1,y1] = meshgrid(1:size(im,2),1:size(im,1));
        
        % Create the requested coordinates
        [x,y] = meshgrid(x_start:x_end,y_start:y_end);
        
        % Use transformation tform to compute x2, y2 corresponding to x, y
        % Get the homogeneous X, Y coordinates
        h_XY = ones(size(x,1), size(x,2), 3);
        h_XY(:, :, 1) = x;
        h_XY(:, :, 2) = y;

        % Transform the homogeneous coordinates
        t_XY = transform(h_XY, tform);
        x2 = t_XY(:,:,1);
        y2 = t_XY(:,:,2);

        % Interpolate x2 and y2 from the image
        im2 = interp2(x1, y1, im, x2, y2, 'linear');
        
        % Zero out-of-bounds values
        im2(isnan(im2)) = 0;
    catch err
        disp(strcat('ERROR: ', err.identifier));
        im2 = [];
    end
end

