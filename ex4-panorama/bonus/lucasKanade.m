function [ tform, motion ] = lucasKanade( I1, I2, rotFlag)
%LUCASKANADE implementation of LK algorithm.
% I1,I2 are two grayscale images. rotFlag whether we want to calculate a 
% rotation.

    narginchk(3, 3);
    nargoutchk(0, 2);

    try
        EPSILON = 1e-3; % Epsilon value for convergence test.
        PYR_FILTER_SIZE = 4; % Pyramid filter size.
        MAX_LEVEL = 10; % Maximal number of levels in pyramid.
        BLUR_SIZE = 3; % Blur kernel size.
        MAX_ITER = 300; % Maximum number of iterations.
        % We crop the image in order avoid edge effects when deriving or
        % blurring the image.
        % We must crop at least BLUR_SIZE / 2 since at this distance from
        % the border we don't get edge effects caused by the blurring.
        CROP_MIN = ceil(BLUR_SIZE / 2) + 1; % Minimal crop pixels.
        CROP_PERCENT = 10; % When cropping by percentage, crop 10%
                           % (in order to avoid boundaries in rotations).
        LAST_PYR_LEVEL = 2; % Skip level 1 if we can
        MIN_PYR_LEVELS = 2; % Don't skip levels if we have only 2 levels or less
        PRINT_MODE = 0; % 1 to print progress
        
        % Compute a Gaussian pyramid for both images of k levels, pyr1 and pyr2
        [pyr1, ~] = gaussianPyramid(I1, MAX_LEVEL, PYR_FILTER_SIZE);
        [pyr2, ~] = gaussianPyramid(I2, MAX_LEVEL, PYR_FILTER_SIZE);

        % Get the pyramid size
        pyr_size = size(pyr1);
        pyr_size = pyr_size(1);

        % Check if we have too few levels
        if pyr_size <= MIN_PYR_LEVELS
            LAST_PYR_LEVEL = 1; % Don't skip levels
        end
        
        % Start with some initial guess (no motion)
        motion = zeros(1,3);

        diverges = false;
        
        for i = pyr_size:-1:LAST_PYR_LEVEL
            % Crop to the minimal possible value by default.
            pyr_boundary = CROP_MIN;
            
            if rotFlag == true
                % For rotation, set the boundary to CROP_PERCENT%
                pyr_boundary = round(size(pyr1{i}, 2) * CROP_PERCENT / 100);
                
                if pyr_boundary < CROP_MIN
                    pyr_boundary = CROP_MIN;
                end
            end
            
            % Update s according to this level
            motion(1:2) = motion(1:2) .* 2;

            Im1 = pyr1{i};
            Im2 = pyr2{i};

            % Blur the images
            Im1 = blurInImageSpace(Im1, BLUR_SIZE);
            Im2 = blurInImageSpace(Im2, BLUR_SIZE);

            % Compute the derivative images Ix, Iy on Im2
            [Ix, Iy] = convDerivative(Im2);

            % Get the cropped indices
            subset_m = (pyr_boundary+1):(size(Im2, 1) - pyr_boundary);
            subset_n = (pyr_boundary+1):(size(Im2, 2) - pyr_boundary);

            % Crop the derivatives
            Ix = Ix(subset_m, subset_n);
            Iy = Iy(subset_m, subset_n);

            % Compute the equation matrix A
            Ix_2 = Ix.^2;
            Iy_2 = Iy.^2;
            Ix_y = Ix.*Iy;
            
            % Compute A for motion only
            A = [sum(Ix_2(:)), sum(Ix_y(:)), 0; ...
                 sum(Ix_y(:)), sum(Iy_2(:)), 0; ...
                 0           , 0           , 1];

            if rotFlag == true
                % Append rotational values for A
                width = size(Ix, 2);
                height = size(Ix, 1);
                half_w = round(width/2);
                half_h = round(height/2);
                
                % Center the coordinates around the center of the image
                % because we rotate around the center of the image, so we
                % change the origin.
                [X, Y] = meshgrid((1 - half_w):(width - half_w), (1 - half_h):(height - half_h));
                
                % Calculate a13, a23, a31, a32, a33
                Ixy_rot = (Iy.*X - Ix.*Y);
                A(3, :) = [sum(Ix(:).*Ixy_rot(:)) sum(Iy(:).*Ixy_rot(:)) sum(Ixy_rot(:).^2)];
                A(1:2, 3) = [sum(Ix(:).*Ixy_rot(:)) ; sum(Iy(:).*Ixy_rot(:))];
            end
            
            first_iter = true;
            j = 0;
            motion_iter = [0 0 0];

            while (first_iter || any(abs(motion_iter) > EPSILON)) && (j < MAX_ITER)
                j = j + 1;
                
                % Warp Im1 according to the current motion estimate to get Im3
                T = [ cos(motion(3)) -sin(motion(3)) motion(1); ...
                      sin(motion(3)) cos(motion(3)) motion(2) ; ...
                      0              0              1 ];
                Im3 = imageWarp(Im1, inv(T), [1 1], size(Im1));
                
                % Let It be the difference between Im2 and Im3
                It = Im2 - Im3;
                It = It(subset_m, subset_n); % Crop It

                % Compute b
                Ix_t = Ix.*It;
                Iy_t = Iy.*It;
                b = [-sum(Ix_t(:)) ; -sum(Iy_t(:)) ; 0];
                
                if rotFlag == true
                    % Update b for rotation
                    b(3) = -sum(Ixy_rot(:).*It(:));
                end

                % Solve for the motion equations and get s^ (motion_iter)
                motion_iter = (A\b)';
                
                % Update s (motion) by s^ (motion_iter)
                if rotFlag == false
                    motion = motion + motion_iter;
                else
                    % In order to calculate the new motion we need to use a
                    % transformation.
                    T = [ cos(motion_iter(3))  sin(motion_iter(3))  motion_iter(1); ...
                          -sin(motion_iter(3)) cos(motion_iter(3))  motion_iter(2) ; ...
                          0                    0                1 ];
                    motion_tran = T * [motion(1); motion(2); 1];
                    motion = [motion_tran(1) motion_tran(2) motion(3) + motion_iter(3)]; 
                    
                end
                
                first_iter = false;
            end
            
            if (j == MAX_ITER)
                diverges = true;
            end
        end
        
        if diverges
            warning('LK does not converge');
        end
        
        if diverges && rotFlag
            % LK did not converge and we are allowing rotation
            % Try again assuming no rotation
            if PRINT_MODE == 1
                disp('Retrying with no rotation...');
            end
            
            [ tform, motion ] = lucasKanade(Im1, Im2, 0);
        else
            % Update the motion for skipped levels
            motion(1:2) = motion(1:2) .* (2 ^ (LAST_PYR_LEVEL - 1));
            
            % Create the resulting trasnformation
            tform = [ cos(motion(3)) -sin(motion(3)) motion(1); sin(motion(3)) cos(motion(3)) motion(2) ; 0 0 1 ];
            tform = inv(tform);
        end
        
    catch err
        disp(strcat('ERROR: ', err.identifier));
        motion = [];
        tform = [];
        return;
    end
end

