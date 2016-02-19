function [ stereoVid ] = createStereoVideo(imgDirectory, nViews)
    %
    % This function gets an image directory and create a stereo movie with
    % nViews. It does the following
    %
    % 1. Match transform between pairs of images.
    % 2. Convert the transfromations to a common co ordinate system.
    % 3. Determine the size of each panoramic frame.
    % 4. Render each view.
    % 5. Create a movie from all the views.
    %
    % Arguments:
    % imgDirectory - A string with the path to the directory of the images
    % nView - The numb er of views to extract from each image
    %
    % Returns:
    % stereoVid - a movie which includes all the panoramic views
    %
    narginchk(2, 2);
    nargoutchk(0, 1);
    
    try
        ROT_FLAG = 0; % 1 to enable rotation detection in LK
        USE_BARCODE = 0; % 1 to enable barcode blending
        PRINT_MODE = 0; % 1 to print progress

        % Load all the images in imgDirectory
        imgs = loadImages( imgDirectory );

        % Get the number of images
        imgs_size = size(imgs, 4);

        % Create an empty transformation cell array for n transformation
        transformations = cell(imgs_size, 1);

        if PRINT_MODE == 1
            disp(['Calculating transformation 1 of ', num2str(imgs_size), '...']);
        end
        
        transformations{1} = eye(3);

        % Set the previous image to the first image
        prev_image = 1;
        new_size = 1;
        new_imgs = zeros(size(imgs));
        new_imgs(:,:,:,1) = imgs(:,:,:,1);

        % Calculate the transformations between pairs of images
        for i = 2:imgs_size
            if PRINT_MODE == 1
                disp(['Calculating transformation ', num2str(i), ' of ', num2str(imgs_size), '...']);
            end
            transformations{new_size + 1} = ...
                lucasKanade(rgb2gray(imgs(:,:,:,prev_image)), rgb2gray(imgs(:,:,:,i)), ROT_FLAG);

            % Calculate the offset relative to the previous image, which
            % enables us to know what direction the next image moves.
            rel_offset = transformations{new_size + 1} * [1 ; 1 ; 1];

            % Use this image only if we are moving right
            if rel_offset(1) >= 1
                prev_image = i;
                new_size = new_size + 1;
                new_imgs(:,:,:,new_size) = imgs(:,:,:,i);
            else
                % We don't insert images that move to the left.
                warning(['Invalid transformation (left movement), skipping image #', num2str(i)]);
            end
        end

        % Remove unused transformations
        transformations((new_size + 1) : end) = [];

        % Set the new images array and size (without left)
        imgs_size = new_size;
        imgs = new_imgs(:,:,:,1:new_size);

        % Calculate the transformations from each image to panorama coordinates
        Tout  = imgToPanoramaCoordinates(transformations);

        % Calculate the panorama frame size
        [ panoramaSize, offset ] = calculatePanoramaSize(imgs, Tout);

        % When there is an overflow (transformed images are getting out of the boundaries)
        % change cordinates according to the overflow.
        Toffset = [ 1 0 -offset(2); 0 1 -offset(1); 0 0 1];
        
        % Add offset to all transformations.
        for i = 1:imgs_size
            Tout{i} = Toffset * Tout{i};
        end
        
        % Calculate the strip width for boundaries.
        stripWidth = size(imgs, 2) / nViews;
        stripWidth = round(stripWidth);

        % Calculate the center of the first view
        center = 1 + stripWidth/2;
        j = 1;

        % Preallocate the video
        stereoVid(nViews) = struct('cdata',[],'colormap',[]);

        for i = 1:nViews
            if PRINT_MODE == 1
                disp(['Calculating frame ', num2str(i), ' of ', num2str(nViews), '...']);
            end

            % Calculate the centers for this view
            imgSliceCenterX = ones(1, imgs_size) * center;

            % Render the current view (either normally or using barcode
            % blending)
            if USE_BARCODE
                [frame, notOK] = barcodeBlending(panoramaSize, imgs, Tout, imgSliceCenterX, stripWidth / 2);
            else
                [frame, notOK] = renderPanoramicFrame(panoramaSize, imgs, Tout, imgSliceCenterX, stripWidth / 2);
            end

            if ~notOK
                % Trim the image if too large
                frame = frame(1 : panoramaSize(1), 1 : panoramaSize(2), :);
                
                % Clip out of range pixel colors
                frame = max(min(frame, 1), 0);
                
                stereoVid(j) = im2frame(frame);
                j = j + 1;
            end

            % Calculate the center of the next view
            center = center + stripWidth;
        end

        % Trim the movie if too long
        stereoVid(j:end) = [];

        if PRINT_MODE == 1
            disp('Done!');
        end

    catch err
        disp(strcat('ERROR: ', err.identifier));
        stereoVid = [];
    end
    
end
