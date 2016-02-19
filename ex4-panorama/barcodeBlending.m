function [ panoramaFrame, frameNotOK ] = barcodeBlending( panoSize, input_imgs, T, imgSliceCenterX, halfSliceWidthX)
%barcodeBlending Renders a panorama using barcode blending

    narginchk(5, 5);
    nargoutchk(0, 2);

    try
        MAX_LEVELS = 10; % Maximal number of pyramid levels.
        PYR_FILTER_SIZE = 4; % Pyramid image filter size.
        PYR_MASK_FILTER_SIZE = 4; % Pyramid mask filter size.
        PRINT_MODE = 0; % 1 to print progress.
        
        frameNotOK = false;

        % Render the odd strips
        if PRINT_MODE == 1
            disp('  Rendering odd strips...');
        end
        [ oddPanorama, frameNotOK1 ] = renderPanoramicFrame( panoSize, ...
                                                         input_imgs(:,:,:,1:2:end), ...
                                                         T(1:2:end), ...
                                                         imgSliceCenterX(1:2:end), ...
                                                         halfSliceWidthX);


        % Render the even strips
        if PRINT_MODE == 1
            disp('  Rendering even strips...');
        end
        [ evenPanorama, frameNotOK2 ] = renderPanoramicFrame( panoSize, ...
                                                         input_imgs(:,:,:,2:2:end), ...
                                                         T(2:2:end), ...
                                                         imgSliceCenterX(2:2:end), ...
                                                         halfSliceWidthX);

        % Check if any rendering failed
        if frameNotOK1 || frameNotOK2
            frameNotOK = true;
            panoramaFrame = [];
            return;
        end

        % Blend the images
        if PRINT_MODE == 1
            disp('  Blending images...');
        end

        nFiles = size(input_imgs, 4);

        % Create the empty white panorama and calculate the strip corners
        mask = ones(panoSize);
        strip_corners = calculatePanoramicBorders(input_imgs, T, panoSize, imgSliceCenterX, halfSliceWidthX);

        % Set odd strips to black
        for i = 1:2:nFiles;
            if (ceil(strip_corners(2, 1, i))) > 0
                mask(:, ceil(strip_corners(2, 1, i)) : ceil(strip_corners(2, 2, i))) = 0;
            end
        end

        % Trim the odd and even panoramas to the panorama size
        y = 1 : panoSize(1);
        x = 1 : panoSize(2);
        mask = mask(y, x);
        evenPanorama = evenPanorama(y, x, :);
        oddPanorama = oddPanorama(y, x, :);

        % Blend the images using the barcode mask
        panoramaFrame = ...
            blendRGBImages(evenPanorama, oddPanorama, mask, MAX_LEVELS, PYR_FILTER_SIZE, PYR_MASK_FILTER_SIZE);

        % Check if we have any elements
        if numel(panoramaFrame) == 0
            frameNotOK = true;
            panoramaFrame = [];
        end
        
    catch err
        disp(strcat('ERROR: ', err.identifier));
        panoramaFrame = [];
        frameNotOK = true;
    end
end

